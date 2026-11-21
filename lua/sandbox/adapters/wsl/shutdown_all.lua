---@module 'sandbox.adapters.wsl.shutdown_all'
---@brief Shuts down the WSL2 VM and all running distros (`wsl --shutdown`),
--- distinct from stopping a single named distro.

local run_argv = require("sandbox.util.run_argv")

local M = {}

--- @param on_done? fun(ok: boolean, err: string|nil) Optional: when given, runs asynchronously (with a
---        progress indicator) and delivers exactly the values the synchronous form returns.
---@return boolean ok
---@return string|nil err
function M.shutdown_all(on_done)
  return run_argv.captured({ "wsl", "--shutdown" }, run_argv.ok_or_err, on_done)
end

return M
