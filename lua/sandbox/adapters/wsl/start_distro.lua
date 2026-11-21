---@module 'sandbox.adapters.wsl.start_distro'
---@brief Starts a WSL distro by launching a no-op command inside it.
---@description
--- WSL has no explicit "start" command. Launching any process in a stopped
--- distro brings it to Running state. A no-op `echo` is used for this purpose.

local run_argv = require("sandbox.util.run_argv")

local M = {}

---@param name string
---@param on_done? fun(ok: boolean, err: string|nil) Optional: when given, runs asynchronously (with a progress
---       indicator) and delivers exactly the values the synchronous form returns.
---@return boolean ok
---@return string|nil err
function M.start_distro(name, on_done)
  -- WSL distros start implicitly when a command is executed inside them.
  -- Running `echo` is the canonical no-op start trigger. Booting a stopped
  -- distro takes seconds, which is why the user command passes `on_done`.
  return run_argv.captured({ "wsl", "-d", name, "--", "echo" }, run_argv.ok_or_err, on_done)
end

return M
