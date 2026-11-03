---@module 'sandbox.util.run_once'
--- One attached, throwaway container run for the engines that share the docker CLI (docker,
--- podman, nerdctl): argv building and the process lifecycle behind `containers.run_once`.
---
--- The container always runs with `--rm`, attached, and under a name this module chooses when the
--- caller gave none, so a timeout or a cancel can stop the CONTAINER (`kill`, then `rm -f`) and not
--- just the CLI process in front of it: killing only the CLI leaves the container running under the
--- daemon. Headless: no window, no notification, usable without `setup()`.
---@see sandbox.core.usecases.containers.run_once

local M = {}

--- The process spawner (`vim.system`). A field so specs can replace it.
---@type fun(cmd: string[], opts: table, on_exit?: fun(res: table)): table
M.system = vim.system

--- A name no running container has: one per call.
local seq = 0

---@return string
local function unique_name()
  seq = seq + 1
  return ("sandbox-once-%d-%d"):format(vim.uv.os_getpid(), seq)
end

---@param s any
---@return boolean
local function plain(s)
  return type(s) == "string" and s ~= "" and not s:find("[,\r\n%z]")
end

---@param s any
---@return boolean
local function option_safe(s)
  return type(s) == "string" and s ~= "" and s:sub(1, 1) ~= "-"
end

--- The argv of `<bin> run`. Mounts use `--mount type=bind,...` rather than `-v src:dst[:ro]`
--- because a Windows source path (`C:\x`) holds a colon.
---@param bin string
---@param opts Sandbox.RunOnceOpts
---@return string[]|nil argv
---@return string|nil err
---@return string|nil name # the container name in use
function M.argv(bin, opts)
  if type(opts) ~= "table" or type(opts.image) ~= "string" or opts.image == "" then
    return nil, "run_once: image is required"
  end
  -- The image is positional and the name is an argument of `kill`/`rm`: a leading `-` would be
  -- read as an option (`kill -a`).
  if not option_safe(opts.image) then
    return nil, "run_once: image must not start with '-'"
  end
  if opts.name ~= nil and (not option_safe(opts.name) or opts.name:find("[^%w_.%-]")) then
    return nil, "run_once: name must be letters, digits, '_', '.' or '-' and not start with '-'"
  end
  local name = opts.name or unique_name()
  local argv = { bin, "run", "--rm", "--name", name }
  argv[#argv + 1] = "--network"
  argv[#argv + 1] = (type(opts.network) == "string" and opts.network ~= "") and opts.network or "none"
  if type(opts.workdir) == "string" and opts.workdir ~= "" then
    vim.list_extend(argv, { "-w", opts.workdir })
  end
  for _, m in ipairs(opts.mounts or {}) do
    if not plain(m.src) or not plain(m.dst) then
      return nil, "run_once: a mount needs a src and dst without commas or line breaks"
    end
    local spec = ("type=bind,source=%s,target=%s%s"):format(m.src, m.dst, m.ro and ",readonly" or "")
    vim.list_extend(argv, { "--mount", spec })
  end
  local keys = {}
  for k in pairs(opts.env or {}) do
    keys[#keys + 1] = k
  end
  table.sort(keys)
  for _, k in ipairs(keys) do
    vim.list_extend(argv, { "-e", ("%s=%s"):format(k, opts.env[k]) })
  end
  argv[#argv + 1] = opts.image
  vim.list_extend(argv, opts.command or {})
  return argv, nil, name
end

---@class Sandbox.RunOnceResult
---@field code integer # the container command's exit code; -1 when it could not be started
---@field timed_out boolean
---@field cancelled boolean
---@field error? string # why it could not be started

--- Run the container and stream its output.
---@param bin string # "docker"|"podman"|"nerdctl"
---@param opts Sandbox.RunOnceOpts
---@param on_line? fun(stream: "stdout"|"stderr", line: string)
---@param on_exit fun(result: Sandbox.RunOnceResult)
---@return { cancel: fun() } handle
function M.run(bin, opts, on_line, on_exit)
  local lines = require("lib.nvim.system.lines")
  local argv, err, name = M.argv(bin, opts)
  local finished, timed_out, cancelled = false, false, false
  local timer

  local function finish(result)
    if finished then
      return
    end
    finished = true
    if timer and not timer:is_closing() then
      timer:stop()
      timer:close()
    end
    vim.schedule(function()
      on_exit(result)
    end)
  end

  if not argv then
    finish({ code = -1, timed_out = false, cancelled = false, error = err })
    return { cancel = function() end }
  end

  local collectors = { stdout = lines.collector(), stderr = lines.collector() }
  local pending = {}
  local function emit(stream, batch)
    if on_line and #batch > 0 then
      pending[#pending + 1] = { stream, batch }
      vim.schedule(function()
        local item = table.remove(pending, 1)
        if item then
          for _, line in ipairs(item[2]) do
            on_line(item[1], line)
          end
        end
      end)
    end
  end
  local function handler(stream)
    return function(_, data)
      if data then
        emit(stream, collectors[stream].feed(data))
      end
    end
  end

  local obj
  local ok, spawn_err = pcall(function()
    obj = M.system(argv, {
      text = true,
      stdout = handler("stdout"),
      stderr = handler("stderr"),
    }, function(res)
      for _, stream in ipairs({ "stdout", "stderr" }) do
        local last = collectors[stream].flush()
        if last then
          emit(stream, { last })
        end
      end
      if timed_out or cancelled then
        -- The CLI died with the container; make sure the container is really gone.
        pcall(M.system, { bin, "rm", "-f", name }, { text = true })
      end
      finish({
        code = res.code,
        timed_out = timed_out,
        cancelled = cancelled,
        error = nil,
      })
    end)
  end)
  if not ok then
    finish({ code = -1, timed_out = false, cancelled = false, error = tostring(spawn_err) })
    return { cancel = function() end }
  end

  --- Stop the container (not just the CLI in front of it), then the CLI.
  local function stop()
    pcall(M.system, { bin, "kill", name }, { text = true }, function()
      pcall(M.system, { bin, "rm", "-f", name }, { text = true })
    end)
    if obj and obj.kill then
      pcall(obj.kill, obj, 15)
    end
  end

  if type(opts.timeout_ms) == "number" and opts.timeout_ms > 0 then
    timer = vim.defer_fn(function()
      if not finished then
        timed_out = true
        stop()
      end
    end, opts.timeout_ms)
  end

  return {
    cancel = function()
      if finished or cancelled then
        return
      end
      cancelled = true
      stop()
    end,
  }
end

return M
