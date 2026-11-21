---@module 'sandbox.adapters.wsl.import_distro'
---@brief Imports a WSL distro from a tarball (`wsl --import <name> <install-dir> <tar-path>`).

local run_argv = require("sandbox.util.run_argv")

local M = {}

---@param name string new distro name
---@param install_path string directory the distro's VHD will be installed into
---@param tar_path string source .tar file path
--- @param on_done? fun(ok: boolean, err: string|nil) Optional: when given, runs asynchronously (with a
---        progress indicator) and delivers exactly the values the synchronous form returns.
---@return boolean ok
---@return string|nil err
function M.import_distro(name, install_path, tar_path, on_done)
  return run_argv.captured({ "wsl", "--import", name, install_path, tar_path }, run_argv.ok_or_err, on_done)
end

return M
