-- The user commands that talk to a daemon must not make the editor wait for it.
--
-- Found by `testing perf` (2026-11-21, sandbox 1204 ms blocked over 46 starts): `:Sandbox container start`,
-- `rename`, `cp`, the image/volume/network lists, `registry logout`, `wsl list/start/stop` and the engine probe of
-- `:Sandbox engine get/reset` each started their CLI and then sat in `vim.system(...):wait()` -- 60-200 ms with
-- stand-ins, the full daemon connect (380-640 ms) or seconds (`docker start`, a `wsl -d` that boots the distro) on a
-- real machine, and forever on a hung daemon.
--
-- The fake `vim.system` below is what makes "does not wait" checkable: its `wait()` throws, so any path that still
-- waits fails, and it never exits by itself -- the test calls the exit callback by hand, which is the moment the
-- command's answer may appear and not one tick before. Nothing real is started.
---@diagnostic disable: need-check-nil, duplicate-set-field
local ui_reset = require("TESTS.sandbox.helpers.ui_reset")

---@class NoWait.Spawn
---@field cmd string[]
---@field opts table
---@field on_exit fun(obj: table)|nil

--- Every module of the plugin except its config (whose live options a case adjusts and restores).
---@param name any
---@return boolean
local function is_plugin_module(name)
  return type(name) == "string"
    and (name == "sandbox" or name:find("^sandbox%.") ~= nil)
    and name:find("^sandbox%.config") == nil
end

describe("user commands do not wait for the engine", function()
  local real_system
  ---@type NoWait.Spawn[]
  local spawned
  ---@type { level: string, msg: string }[]
  local notices
  local views
  local config
  local prev_style, prev_named

  --- The process of `spawned[i]` writes `out` and exits with `code`.
  ---@param i integer
  ---@param code integer
  ---@param out? string
  local function exit(i, code, out)
    local s = spawned[i]
    assert.is_function(s.on_exit, table.concat(s.cmd, " ") .. " was started without an exit callback (waited for)")
    if out and type(s.opts.stdout) == "function" then
      s.opts.stdout(nil, out)
    end
    s.on_exit({ code = code, signal = 0, stdout = nil, stderr = nil })
  end

  ---@param level string
  ---@param text string
  ---@return boolean
  local function noted(level, text)
    for _, n in ipairs(notices) do
      if n.level == level and n.msg:find(text, 1, true) then
        return true
      end
    end
    return false
  end

  --- Wait for the `vim.schedule`d answer to land.
  ---@param check fun(): boolean
  local function settle(check)
    vim.wait(1000, check, 5)
  end

  before_each(function()
    spawned, notices, views = {}, {}, {}
    real_system = vim.system
    vim.system = function(cmd, opts, on_exit)
      spawned[#spawned + 1] = { cmd = cmd, opts = opts or {}, on_exit = on_exit }
      ---@diagnostic disable-next-line: return-type-mismatch
      return {
        pid = 4242,
        wait = function()
          error("the editor waited for `" .. table.concat(cmd, " ") .. "`", 0)
        end,
        kill = function() end,
      }
    end

    -- Fresh modules: every adapter must bind the real `run_argv` (other specs install a fake one), and every
    -- command module the notify fake below.
    for name in pairs(package.loaded) do
      if is_plugin_module(name) then
        package.loaded[name] = nil
      end
    end
    package.preload["sandbox.util.run_argv"] = nil
    package.loaded["sandbox.notify"] = {
      info = function(msg)
        notices[#notices + 1] = { level = "info", msg = msg }
      end,
      warn = function(msg)
        notices[#notices + 1] = { level = "warn", msg = msg }
      end,
      error = function(msg)
        notices[#notices + 1] = { level = "error", msg = msg }
      end,
    }
    for _, view in ipairs({ "image_list_view_docker", "volume_list_view", "network_list_view" }) do
      package.loaded["sandbox.ui." .. view] = function(items)
        views[#views + 1] = { view = view, items = items }
      end
    end

    config = require("sandbox.config")
    prev_style, prev_named = config.options.progress_style, config.engine_named
    -- Headless and observable: no window, no toast.
    config.options.progress_style = "statusline"
    config.engine_named = false
    vim.g.sandbox_engine = "docker"
  end)

  after_each(function()
    vim.system = real_system
    vim.g.sandbox_engine = nil
    config.options.progress_style = prev_style
    config.engine_named = prev_named
    for name in pairs(package.loaded) do
      if is_plugin_module(name) then
        package.loaded[name] = nil
      end
    end
    ui_reset.restore()
  end)

  --- command, the argv it must start, what the success says, how to run it
  local CASES = {
    {
      name = "container start",
      argv = "docker start sbx-db",
      says = "Container started successfully: sbx-db",
      run = function()
        require("sandbox.bindings.usrcmds.container_commands").start("sbx-db")
      end,
    },
    {
      name = "container rename",
      argv = "docker rename sbx-web sbx-new",
      says = "Container renamed: sbx-web -> sbx-new",
      run = function()
        require("sandbox.bindings.usrcmds.container_commands").rename("sbx-web", "sbx-new")
      end,
    },
    {
      name = "container cp",
      argv = "docker cp sbx-web:/etc/hostname ./h.txt",
      says = "Copied: sbx-web:/etc/hostname -> ./h.txt",
      run = function()
        require("sandbox.bindings.usrcmds.container_commands").cp("sbx-web:/etc/hostname", "./h.txt")
      end,
    },
    {
      name = "registry logout",
      argv = "docker logout ghcr.io",
      says = "Logged out of ghcr.io",
      run = function()
        require("sandbox.bindings.usrcmds.registry_commands").logout("ghcr.io")
      end,
    },
    {
      name = "wsl start",
      argv = "wsl -d sbx-wsl -- echo",
      says = "WSL distro started: sbx-wsl",
      run = function()
        require("sandbox.bindings.usrcmds.wsl_commands").start("sbx-wsl")
      end,
    },
    {
      name = "wsl stop",
      argv = "wsl --terminate sbx-wsl",
      says = "WSL distro terminated: sbx-wsl",
      run = function()
        require("sandbox.bindings.usrcmds.wsl_commands").stop("sbx-wsl")
      end,
    },
  }

  for _, case in ipairs(CASES) do
    it(case.name .. " returns before the CLI exits and reports when it does", function()
      case.run()

      assert.are.equal(1, #spawned)
      assert.are.equal(case.argv, table.concat(spawned[1].cmd, " "))
      assert.are.same({}, notices, "answered before the process exited")

      exit(1, 0)
      settle(function()
        return #notices > 0
      end)
      assert.is_true(noted("info", case.says), vim.inspect(notices))
    end)
  end

  it("container start reports the CLI's error when it fails", function()
    require("sandbox.bindings.usrcmds.container_commands").start("sbx-db")
    exit(1, 1, "Error response from daemon: No such container: sbx-db\n")
    settle(function()
      return #notices > 0
    end)
    assert.is_true(noted("error", "No such container: sbx-db"), vim.inspect(notices))
  end)

  local LISTS = {
    {
      group = "image",
      argv = "docker images --format {{json .}}",
      view = "image_list_view_docker",
      field = "repository",
    },
    { group = "volume", argv = "docker volume ls --format {{json .}}", view = "volume_list_view", field = "name" },
    { group = "network", argv = "docker network ls --format {{json .}}", view = "network_list_view", field = "name" },
  }

  for _, list in ipairs(LISTS) do
    it(list.group .. " list opens its view once the CLI answers, not before", function()
      require("sandbox.bindings.usrcmds." .. list.group .. "_commands").list()

      assert.are.equal(1, #spawned)
      assert.are.equal(list.argv, table.concat(spawned[1].cmd, " "))
      assert.are.same({}, views)

      -- A daemon warning on stderr must not turn into a parse error: a list parses stdout only.
      if type(spawned[1].opts.stderr) == "function" then
        spawned[1].opts.stderr(nil, "WARNING: context is deprecated\n")
      end
      exit(1, 0, '{"ID":"x1","Repository":"alpine","Name":"alpine"}\n')
      settle(function()
        return #views > 0
      end)
      assert.are.equal(list.view, views[1].view)
      assert.are.equal("alpine", views[1].items[1][list.field])
      assert.are.same({}, notices)
    end)
  end

  it("wsl list opens its buffer once wsl.exe answers, not before", function()
    require("sandbox.bindings.usrcmds.wsl_commands").list()
    local before = vim.api.nvim_get_current_buf()

    assert.are.equal("wsl --list --verbose", table.concat(spawned[1].cmd, " "))
    assert.are.equal(before, vim.api.nvim_get_current_buf())

    exit(1, 0, "  NAME      STATE           VERSION\n* sbx-wsl   Stopped         2\n")
    settle(function()
      return vim.api.nvim_get_current_buf() ~= before
    end)
    local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
    assert.is_truthy(text:find("sbx-wsl", 1, true), text)
  end)

  describe("engine detection", function()
    local utils

    before_each(function()
      vim.g.sandbox_engine = nil
      package.loaded["sandbox.util.project_config"] = {
        read_engine_override = function()
          return nil, false
        end,
      }
      utils = require("sandbox.engine_utils")
      utils.is_executable = function(cmd)
        return cmd == "podman" or cmd == "docker"
      end
    end)

    it("engine get probes in the background and reports after the answer", function()
      require("sandbox.bindings.usrcmds.engine_commands").get()

      assert.are.equal(1, #spawned)
      assert.are.equal("podman version", table.concat(spawned[1].cmd, " "))
      assert.are.same({}, notices)

      exit(1, 0)
      settle(function()
        return #notices > 0
      end)
      assert.is_true(noted("info", "Active engine: podman (detected)"), vim.inspect(notices))
    end)

    it("falls through to the next engine when the preferred one does not answer", function()
      require("sandbox.bindings.usrcmds.engine_commands").get()
      exit(1, 125)
      settle(function()
        return #spawned > 1
      end)
      assert.are.equal("docker version", table.concat(spawned[2].cmd, " "))
      exit(2, 0)
      settle(function()
        return #notices > 0
      end)
      assert.is_true(noted("info", "Active engine: docker (detected)"), vim.inspect(notices))
    end)

    it("engine reset forgets, probes in the background, and reports after the answer", function()
      utils.probe("podman", function() end)
      exit(1, 0)
      settle(function()
        return utils.responds("podman") ~= nil
      end)

      require("sandbox.bindings.usrcmds.engine_commands").reset()
      assert.are.equal(2, #spawned, "reset must ask afresh")
      assert.are.same({}, notices)

      exit(2, 0)
      settle(function()
        return #notices > 0
      end)
      assert.is_true(noted("info", "Session engine override cleared; using podman"), vim.inspect(notices))
    end)

    it("a second question while a probe runs joins it instead of starting another process", function()
      local answers = {}
      utils.probe("podman", function(a)
        answers[#answers + 1] = a
      end)
      utils.probe("podman", function(a)
        answers[#answers + 1] = a
      end)
      assert.are.equal(1, #spawned)

      exit(1, 0)
      settle(function()
        return #answers == 2
      end)
      assert.are.same({ true, true }, answers)
      -- Remembered: asking again starts nothing and answers at once.
      assert.is_true(utils.responds("podman"))
      assert.are.equal(1, #spawned)
    end)

    it("a probe orphaned by forget() answers nobody and leaves no memo", function()
      local answers = {}
      utils.probe("podman", function(a)
        answers[#answers + 1] = a
      end)
      utils.forget()

      exit(1, 0)
      vim.wait(50)
      assert.are.same({}, answers)

      utils.probe("podman", function(a)
        answers[#answers + 1] = a
      end)
      assert.are.equal(2, #spawned, "the forgotten answer must not be reused")
    end)

    it("the synchronous question waits on a running probe rather than starting a second one", function()
      local job_waits = 0
      vim.system = function(cmd, opts, on_exit)
        spawned[#spawned + 1] = { cmd = cmd, opts = opts or {}, on_exit = on_exit }
        ---@diagnostic disable-next-line: return-type-mismatch
        return {
          -- The probe's process has exited; `wait` hands back its result, as `vim.SystemObj:wait` does.
          wait = function()
            job_waits = job_waits + 1
            return { code = 0 }
          end,
        }
      end
      utils.probe("podman", function() end)
      vim.system = function()
        error("a second process was started", 0)
      end

      assert.is_true(utils.responds("podman"))
      assert.are.equal(1, job_waits)
      assert.are.equal(1, #spawned)
    end)
  end)
end)
