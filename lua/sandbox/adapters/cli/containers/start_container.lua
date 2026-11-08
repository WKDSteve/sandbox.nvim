---@module 'sandbox.adapters.cli.containers.start_container'
--- CLI Adapter (docker, podman, nerdctl): Function to start a container
---
--- One definition for every engine that speaks the docker CLI: `new(bin)` returns the functions for
--- the binary `bin`. The per-engine module of the same name calls it
--- (`sandbox.adapters.<engine>.<group>.<verb>`).

local Shared = {}

--- @param bin string the engine's binary (`docker`, `podman`, `nerdctl`)
--- @return table the functions of this module
function Shared.new(bin)
  local run_argv = require("sandbox.util.run_argv")

  local M = {}

  --- Start a specific container
  --- @param container_id string: ID or name of the container to start
  --- @return boolean ok, string|nil err
  function M.start_container(container_id)
    local ok, output = run_argv.run_blocking_captured({ bin, "start", container_id })

    if not ok then
      return false, output
    end

    return true, nil
  end

  return M
end

return Shared
