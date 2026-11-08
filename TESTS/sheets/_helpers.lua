-- TESTS/sheets/_helpers.lua -- what the sandbox.nvim test sheets need in their child editor. Not a sheet
-- (`testing.sheet` only reads *.sheet.lua); a sheet's first step runs it with `dofile`, the child's cwd is the
-- project root. The directory is in the spec's @cache-inputs, so a change here re-runs the sheets.
--
-- No container engine is ever started. Every way the plugin reaches a CLI is replaced by a fake that answers from
-- the state below and records the argv it was handed: `sandbox.util.run_argv` (both runners), `vim.fn.jobstart`
-- and `vim.fn.termopen` (the fire-and-forget and terminal-buffer paths), and `vim.system` (the liveness probe and
-- logs-follow). A spawn of docker, podman, nerdctl or wsl that is not faked would be a bug of this file: the fakes
-- refuse nothing else, so `_G.other_spawns` records what went past them and the sheets assert it stays empty.
-- Which engines count as installed is `_G.installed`, not the PATH of the machine.

vim.opt.shortmess:append("I")
vim.o.swapfile = false
vim.o.hidden = true

---The project root (the child's cwd when the first step runs).
_G.root = vim.fs.normalize(vim.fn.getcwd())

---@type table<string, boolean> the engines `engine_utils.is_executable` reports; wsl keeps the real answer
_G.installed = { docker = true, podman = true, nerdctl = false }

---@type { argv: string, list: string[], via: string, input: string|nil }[] every faked call (`argv` joined by spaces)
_G.calls = {}

---@type string[] spawns that were not an engine CLI (passed through to the real function)
_G.other_spawns = {}

---@type integer how often a faked `vim.system` process was killed (logs-follow stops its stream that way)
_G.kills = 0

---@type table<string, string> a call whose joined argv starts with a key fails with that output
_G.fail = {}

---The docker containers, in the fields of `docker ps --format '{{json .}}'`.
_G.containers = {
  { ID = "aaa111aaa111aaa1", Names = "sbx-web", State = "running", Image = "alpine" },
  { ID = "bbb222bbb222bbb2", Names = "sbx-db", State = "exited", Image = "postgres:16" },
  { ID = "ccc333ccc333ccc3", Names = "sbx-cache", State = "exited", Image = "redis" },
  { ID = "ddd444ddd444ddd4", Names = "sbx-paused", State = "paused", Image = "alpine" },
}

local ENGINES = { docker = true, podman = true, nerdctl = true, wsl = true, ["wsl.exe"] = true }

---@param argv string[]
---@return boolean
local function is_engine(argv)
  return type(argv) == "table" and ENGINES[argv[1]] == true
end

---@param id string
---@return table|nil
local function container(id)
  for _, c in ipairs(_G.containers) do
    if c.ID == id or c.Names == id or c.ID:sub(1, #id) == id then
      return c
    end
  end
end

local STATE_AFTER = { start = "running", restart = "running", unpause = "running", stop = "exited", kill = "exited" }
STATE_AFTER.pause = "paused"

---What the fake engine answers to `argv`.
---@param argv string[]
---@return boolean ok, string output, integer code
function _G.reply(argv)
  local joined = table.concat(argv, " ")
  for prefix, out in pairs(_G.fail) do
    if joined:sub(1, #prefix) == prefix then
      return false, out, 1
    end
  end
  local verb = argv[2]
  if argv[1] == "wsl" and verb == "--list" then
    return true, "  NAME      STATE      VERSION\n* Ubuntu    Running    2\n  sbx-wsl   Stopped    2\n", 0
  end
  if argv[1] == "podman" and verb == "ps" then
    return true, "[]", 0
  end
  if verb == "ps" then
    local lines = {}
    for i, c in ipairs(_G.containers) do
      lines[i] = vim.json.encode(c)
    end
    return true, table.concat(lines, "\n") .. "\n", 0
  end
  if STATE_AFTER[verb] then
    local c = container(argv[#argv])
    if not c then
      return false, "Error: No such container: " .. argv[#argv], 1
    end
    c.State = STATE_AFTER[verb]
    return true, argv[#argv] .. "\n", 0
  end
  if verb == "inspect" then
    local c = container(argv[3])
    if c then
      return true, vim.json.encode({ { Id = c.ID, Name = "/" .. c.Names, State = { Status = c.State } } }), 0
    end
    return true, vim.json.encode({ { Id = "sha256:feed", RepoTags = { argv[3] } } }), 0
  end
  if verb == "logs" then
    return true, "log line one of " .. argv[#argv] .. "\nlog line two\n", 0
  end
  if verb == "images" then
    return true,
      vim.json.encode({ ID = "img0123456789", Repository = "alpine", Tag = "edge", Size = "7.8MB" }) .. "\n",
      0
  end
  if (verb == "volume" or verb == "network") and argv[3] == "ls" then
    return true,
      vim.json.encode({ Name = "sbx-" .. verb, Driver = verb == "volume" and "local" or "bridge" }) .. "\n",
      0
  end
  if verb == "volume" or verb == "network" then
    if argv[3] == "inspect" then
      return true, vim.json.encode({ { Name = argv[4], Driver = "local" } }), 0
    end
  end
  if verb == "top" then
    return true, "UID PID CMD\nroot 1 sleep 300\n", 0
  end
  if verb == "stats" then
    return true, "CONTAINER CPU % MEM USAGE\n" .. argv[#argv] .. " 0.01% 1MiB\n", 0
  end
  if verb == "history" then
    return true, "IMAGE CREATED SIZE\nimg0123456789 2 weeks ago 7.8MB\n", 0
  end
  return true, "", 0
end

---@param argv string[]
---@param via string
---@param input string|nil
local function record(argv, via, input)
  _G.calls[#_G.calls + 1] = { argv = table.concat(argv, " "), list = vim.deepcopy(argv), via = via, input = input }
end

-- The two runners every adapter calls through the module table (`run_argv.run_*_captured(...)`), so replacing the
-- fields reaches the adapters that are already loaded too.
local run_argv = require("sandbox.util.run_argv")
function run_argv.run_blocking_captured(argv, input)
  record(argv, "blocking", input)
  local ok, out = _G.reply(argv)
  return ok, out
end
function run_argv.run_async_captured(argv, on_done)
  record(argv, "async", nil)
  local ok, out, code = _G.reply(argv)
  vim.schedule(function()
    on_done(ok, out, code)
  end)
  return {
    stop = function() end,
  }
end

local real_jobstart, real_termopen, real_system = vim.fn.jobstart, vim.fn.termopen, vim.system
local job_ids = 9000

---A terminal in the current buffer that shows the argv and the fake answer, as a terminal job would.
---@param argv string[]
---@return integer channel
local function fake_term(argv)
  local _, out = _G.reply(argv)
  local chan = vim.api.nvim_open_term(0, {})
  vim.api.nvim_chan_send(chan, "$ " .. table.concat(argv, " ") .. "\r\n" .. out:gsub("\n", "\r\n"))
  return chan
end

---@diagnostic disable-next-line: duplicate-set-field
vim.fn.jobstart = function(argv, opts)
  if not is_engine(argv) then
    _G.other_spawns[#_G.other_spawns + 1] = vim.inspect(argv)
    return real_jobstart(argv, opts)
  end
  opts = opts or {}
  if opts.term then
    record(argv, "term", nil)
    return fake_term(argv)
  end
  record(argv, "job", nil)
  job_ids = job_ids + 1
  local id = job_ids
  local ok, out, code = _G.reply(argv)
  vim.schedule(function()
    local lines = vim.split(out, "\n", { plain = true })
    if ok and opts.on_stdout then
      opts.on_stdout(id, lines, "stdout")
    elseif not ok and opts.on_stderr then
      opts.on_stderr(id, lines, "stderr")
    end
    if opts.on_exit then
      opts.on_exit(id, code, "exit")
    end
  end)
  return id
end

---@diagnostic disable-next-line: duplicate-set-field
vim.fn.termopen = function(argv, opts)
  if not is_engine(argv) then
    _G.other_spawns[#_G.other_spawns + 1] = vim.inspect(argv)
    return real_termopen(argv, opts)
  end
  record(argv, "term", nil)
  return fake_term(argv)
end

---@diagnostic disable-next-line: duplicate-set-field
vim.system = function(argv, opts, on_exit)
  if not is_engine(argv) then
    _G.other_spawns[#_G.other_spawns + 1] = vim.inspect(argv)
    return real_system(argv, opts, on_exit)
  end
  if type(opts) == "function" then
    on_exit, opts = opts, nil
  end
  opts = opts or {}
  record(argv, "system", nil)
  local ok, out, code = _G.reply(argv)
  local result = { code = code, signal = 0, stdout = ok and out or "", stderr = ok and "" or out }
  local done = false
  local obj = {
    pid = 0,
    wait = function()
      return result
    end,
    kill = function()
      done = true
      _G.kills = _G.kills + 1
    end,
    is_closing = function()
      return done
    end,
    write = function() end,
  }
  vim.schedule(function()
    if type(opts.stdout) == "function" then
      opts.stdout(nil, result.stdout ~= "" and result.stdout or nil)
    end
    if type(opts.stderr) == "function" and result.stderr ~= "" then
      opts.stderr(nil, result.stderr)
    end
    if on_exit and not done then
      on_exit(result)
    end
  end)
  return obj
end

local engine_utils = require("sandbox.engine_utils")
local real_is_executable = engine_utils.is_executable
---@diagnostic disable-next-line: duplicate-set-field
function engine_utils.is_executable(name)
  if _G.installed[name] ~= nil then
    return _G.installed[name]
  end
  return real_is_executable(name)
end
engine_utils.forget()

---How many faked calls so far had exactly this argv (`argv` joined by spaces).
---@param argv string
---@return integer
function _G.called(argv)
  local n = 0
  for _, c in ipairs(_G.calls) do
    if c.argv == argv then
      n = n + 1
    end
  end
  return n
end

---How many times `engine` was asked for its container list (podman's argv differs from docker's and nerdctl's).
---@param engine string
---@return integer
function _G.listed(engine)
  return _G.called(engine == "podman" and "podman ps -a --format json" or (engine .. " ps -a --format {{json .}}"))
end

---The last faked call whose argv starts with `prefix`, or nil.
---@param prefix string
---@return { argv: string, via: string, input: string|nil }|nil
function _G.last(prefix)
  for i = #_G.calls, 1, -1 do
    if _G.calls[i].argv:sub(1, #prefix) == prefix then
      return _G.calls[i]
    end
  end
end

---`argv` was called, or an error naming the calls that were made.
---@param argv string
---@return boolean
function _G.saw(argv)
  if _G.called(argv) > 0 then
    return true
  end
  local seen = {}
  for i, c in ipairs(_G.calls) do
    seen[i] = c.argv
  end
  error(("no call %s; calls: %s"):format(vim.inspect(argv), vim.inspect(seen)), 0)
end

---Forget the calls so far.
function _G.clear()
  _G.calls = {}
end

---Before the next command of a sheet: no calls yet, normal mode, one window on an empty buffer.
function _G.fresh()
  _G.calls = {}
  vim.cmd("stopinsert")
  vim.cmd("enew")
  vim.cmd("silent! only")
  -- A terminal is not wiped when it is hidden, its session lives on: end the earlier ones, so the next command's
  -- buffer gets its plain name (a second session on one container is "... (2)", pinned by exec_second_session_spec).
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[b].buftype == "terminal" then
      vim.api.nvim_buf_delete(b, { force = true })
    end
  end
end

---The only faked call so far is exactly `argv` (joined by spaces), made `via` the given path when one is named.
---@param argv string
---@param via? string "blocking", "async", "job", "term" or "system"
---@return boolean
function _G.only_call(argv, via)
  return #_G.calls == 1 and _G.calls[1].argv == argv and (via == nil or _G.calls[1].via == via)
end

---Whether a toast of sandbox so far holds `text` (plain), read from the popup history.
---@param text string
---@return boolean
function _G.noted(text)
  for _, entry in ipairs(require("lib.nvim.notify.popup").history("sandbox")) do
    if tostring(entry.message):find(text, 1, true) then
      return true
    end
  end
  return false
end

---The number of sandbox toasts so far.
---@return integer
function _G.toasts()
  return #require("lib.nvim.notify.popup").history("sandbox")
end

---`text` holds `part` (plain), or an error that shows the text.
---@param text string
---@param part string
---@return boolean
function _G.has(text, part)
  if not tostring(text):find(part, 1, true) then
    error(("no %s in %s"):format(vim.inspect(part), vim.inspect(text)), 0)
  end
  return true
end

---The lines of a buffer (default the current one) as one string, joined by a newline.
---@param buf integer|nil
---@return string
function _G.text(buf)
  return table.concat(vim.api.nvim_buf_get_lines(buf or 0, 0, -1, false), "\n")
end

---The buffer named `name` (exactly; on Neovim before 0.12 on Windows the path it makes of a `sandbox.nvim://x` name
---counts), or nil.
---@param name string
---@return integer|nil
function _G.buf(name)
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(b) then
      local got = vim.api.nvim_buf_get_name(b):gsub("\\", "/")
      if got == name or (got ~= "" and vim.endswith(got, "/" .. name)) then
        return b
      end
    end
  end
end

---The current buffer's name. Neovim before 0.12 makes a path of `sandbox.nvim://x` on Windows
---(`<cwd>\sandbox.nvim:\x`): the name is given back as the scratch buffers were named.
---@return string
function _G.bufname()
  local name = vim.api.nvim_buf_get_name(0):gsub("\\", "/")
  local at = name:find("sandbox.nvim://", 1, true)
  return at and name:sub(at) or vim.api.nvim_buf_get_name(0)
end

---The floating windows of this tab.
---@return integer[]
function _G.floats()
  return vim.tbl_filter(function(w)
    return vim.api.nvim_win_get_config(w).relative ~= ""
  end, vim.api.nvim_tabpage_list_wins(0))
end

---Whether a float of this tab (a dialog, an input; the toasts are floats too) shows `part` (plain).
---@param part string
---@return boolean
function _G.float_has(part)
  for _, w in ipairs(_G.floats()) do
    if _G.text(vim.api.nvim_win_get_buf(w)):find(part, 1, true) then
      return true
    end
  end
  return false
end

---The focused float asks for `part`: its title (or its text) holds it, and it waits in insert mode.
---@param part string
---@return boolean
function _G.asks(part)
  if vim.api.nvim_win_get_config(0).relative == "" or vim.fn.mode() ~= "i" then
    return false
  end
  local title = vim.api.nvim_win_get_config(0).title
  if type(title) == "table" then
    local chunks = {}
    for i, c in ipairs(title) do
      chunks[i] = type(c) == "table" and c[1] or tostring(c)
    end
    title = table.concat(chunks)
  end
  return tostring(title or ""):find(part, 1, true) ~= nil or _G.text():find(part, 1, true) ~= nil
end

---Whether the drawn screen (floats included) shows `part` (plain) on one row.
---@param part string
---@return boolean
function _G.on_screen(part)
  vim.cmd("redraw")
  for row = 1, vim.o.lines do
    local cells = {}
    for col = 1, vim.o.columns do
      cells[col] = vim.fn.screenstring(row, col)
    end
    if table.concat(cells):find(part, 1, true) then
      return true
    end
  end
  return false
end

---The focused window is a float (an input or a dialog has the focus).
---@return boolean
function _G.in_float()
  return vim.api.nvim_win_get_config(0).relative ~= ""
end

---A fresh, empty temp directory (normalized), created.
---@return string
function _G.tempdir()
  local dir = vim.fs.normalize(vim.fn.tempname())
  vim.fn.mkdir(dir, "p")
  return dir
end

---Write `lines` to `path`, creating its directory.
---@param path string
---@param lines string[]
function _G.write(path, lines)
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  vim.fn.writefile(lines, path)
end

---Focus the container list and put the cursor on the row of container `name`.
---@param name string
---@return boolean
function _G.row(name)
  local b = _G.buf("sandbox.nvim://container-list")
  local win = b and vim.fn.bufwinid(b)
  if not win or win == -1 then
    error("the container list is not shown", 0)
  end
  vim.api.nvim_set_current_win(win)
  for i, line in ipairs(vim.api.nvim_buf_get_lines(b, 0, -1, false)) do
    if line:find(" " .. name .. " ", 1, true) then
      vim.api.nvim_win_set_cursor(win, { i, 0 })
      return true
    end
  end
  error(("no row %s in %s"):format(name, _G.text(b)), 0)
end

---The highlight group on the `[status]` prefix of each row of the container list, in row order.
---@return string[]
function _G.status_groups()
  local b = _G.buf("sandbox.nvim://container-list")
  local ns = vim.api.nvim_create_namespace("sandbox_container_status")
  local out = {}
  for _, m in ipairs(vim.api.nvim_buf_get_extmarks(b, ns, 0, -1, { details = true })) do
    out[m[2] + 1] = m[4].hl_group
  end
  return out
end

---The id of container `name` in the fake state.
---@param name string
---@return string
function _G.id(name)
  for _, c in ipairs(_G.containers) do
    if c.Names == name then
      return c.ID
    end
  end
  error("no container " .. name, 0)
end

require("sandbox").setup({})
