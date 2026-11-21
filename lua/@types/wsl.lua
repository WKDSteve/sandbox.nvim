---@module '@types.wsl'

---@class WslDistro
---@field name string
---@field state "Running"|"Stopped"|string
---@field default boolean

---Delivers the outcome of a WSL command run asynchronously: `ok`, and the error when it failed.
---@alias WslDone fun(ok: boolean, err: string|nil)

---@class WslEngine
---@field list_distros fun(on_done?: fun(distros: WslDistro[]|nil, err: string|nil)): WslDistro[]|nil, string|nil
---@field start_distro fun(name: string, on_done?: fun(ok: boolean, err: string|nil)): boolean, string|nil
---@field stop_distro fun(name: string, on_done?: fun(ok: boolean, err: string|nil)): boolean, string|nil
---@field exec_in_distro fun(name: string, command: string[]|nil): nil
---@field set_default_distro fun(name: string, on_done?: WslDone): boolean, string|nil
---@field set_version_distro fun(name: string, version: integer, on_done?: WslDone): boolean, string|nil
---@field export_distro fun(name: string, path: string, on_done?: WslDone): boolean, string|nil
---@field import_distro fun(name: string, install_path: string, tar_path: string, on_done?: WslDone): boolean, string?
---@field shutdown_all fun(on_done?: WslDone): boolean, string|nil
