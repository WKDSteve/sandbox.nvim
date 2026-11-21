---@module 'sandbox.adapters.wsl.export_distro'
---@brief Exports a WSL distro to a tarball on disk (`wsl --export <name> <path>`).

local run_argv = require("sandbox.util.run_argv")

local M = {}

---@param name string
---@param path string destination .tar file path
--- @param on_done? fun(ok: boolean, err: string|nil) Optional: when given, runs asynchronously (with a
---        progress indicator) and delivers exactly the values the synchronous form returns.
---@return boolean ok
---@return string|nil err
function M.export_distro(name, path, on_done)
  return run_argv.captured({ "wsl", "--export", name, path }, run_argv.ok_or_err, on_done)
end

return M
