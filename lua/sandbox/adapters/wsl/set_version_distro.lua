---@module 'sandbox.adapters.wsl.set_version_distro'
---@brief Toggles a WSL distro between WSL1/WSL2 (`wsl --set-version <name> <1|2>`).

local run_argv = require("sandbox.util.run_argv")

local M = {}

---@param name string
---@param version 1|2
--- @param on_done? fun(ok: boolean, err: string|nil) Optional: when given, runs asynchronously (with a
---        progress indicator) and delivers exactly the values the synchronous form returns.
---@return boolean ok
---@return string|nil err
function M.set_version_distro(name, version, on_done)
  return run_argv.captured({ "wsl", "--set-version", name, tostring(version) }, run_argv.ok_or_err, on_done)
end

return M
