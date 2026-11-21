---@module 'sandbox.adapters.wsl.stop_distro'
---@brief Terminates a running WSL distribution.

local run_argv = require("sandbox.util.run_argv")

local M = {}

---@param name string
---@param on_done? fun(ok: boolean, err: string|nil) Optional: when given, runs asynchronously (with a progress
---       indicator) and delivers exactly the values the synchronous form returns.
---@return boolean ok
---@return string|nil err
function M.stop_distro(name, on_done)
  return run_argv.captured({ "wsl", "--terminate", name }, run_argv.ok_or_err, on_done)
end

return M
