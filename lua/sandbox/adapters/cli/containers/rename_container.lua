---@module 'sandbox.adapters.cli.containers.rename_container'
--- CLI Adapter (docker, podman, nerdctl): Function to rename a container
---
--- One definition for every engine that speaks the docker CLI: `new(bin)` returns the functions for
--- the binary `bin`. The per-engine module of the same name calls it (`sandbox.adapters.<engine>.containers.rename_container`).

local Shared = {}

--- @param bin string the engine's binary (`docker`, `podman`, `nerdctl`)
--- @return table the functions of this module
function Shared.new(bin)
  local run_argv = require("sandbox.util.run_argv")

  local M = {}

  --- Rename a specific container
  --- @param container_id string: ID or name of the container to rename
  --- @param new_name string: new name for the container
  --- @return boolean ok, string|nil err
  function M.rename_container(container_id, new_name)
    local ok, output = run_argv.run_blocking_captured({ bin, "rename", container_id, new_name })

    if not ok then
      return false, output
    end

    return true, nil
  end

  return M
end

return Shared
