---@module 'sandbox.adapters.cli.volumes.create_volume'
--- CLI Adapter (docker, podman, nerdctl): Function to create a volume
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

  --- Create a new named volume
  --- @param name string
  --- @return boolean ok, string|nil err
  function M.create_volume(name)
    local ok, output = run_argv.run_blocking_captured({ bin, "volume", "create", name })

    if not ok then
      return false, output
    end

    return true, nil
  end

  return M
end

return Shared
