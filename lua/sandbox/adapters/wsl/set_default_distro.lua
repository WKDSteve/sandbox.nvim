---@module 'sandbox.adapters.wsl.set_default_distro'
---@brief Sets a WSL distro as the default (`wsl --set-default <name>`).

local run_argv = require("sandbox.util.run_argv")

local M = {}

---@param name string
--- @param on_done? fun(ok: boolean, err: string|nil) Optional: when given, runs asynchronously (with a
---        progress indicator) and delivers exactly the values the synchronous form returns.
---@return boolean ok
---@return string|nil err
function M.set_default_distro(name, on_done)
  return run_argv.captured({ "wsl", "--set-default", name }, run_argv.ok_or_err, on_done)
end

return M
