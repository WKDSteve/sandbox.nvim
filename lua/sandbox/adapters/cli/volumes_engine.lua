---@module 'sandbox.adapters.cli.volumes_engine'
--- Engine Volume Adapter Aggregator
---
--- Combines all volume operations into a unified interface
--- for the ContainerEngine port (specific to Engine).
---
--- Shared by every engine that speaks the docker CLI: `new(name)` builds the aggregate from the modules
--- `sandbox.adapters.<name>.*`, so an engine that overrides one verb is picked up without a copy of this file.

local Shared = {}

--- @param name string the engine's directory (`docker`, `podman`, `nerdctl`)
--- @return table
function Shared.new(name)
  local engine = "sandbox.adapters." .. name

  local list_volumes = require(engine .. ".volumes.list_volumes")
  local create_volume = require(engine .. ".volumes.create_volume")
  local remove_volume = require(engine .. ".volumes.remove_volume")
  local inspect_volume = require(engine .. ".volumes.inspect_volume")
  local prune_volumes = require(engine .. ".volumes.prune_volumes")

  --- Volume operations exposed by the Engine adapter
  return {
    list_volumes = list_volumes.list_volumes,
    create_volume = create_volume.create_volume,
    remove_volume = remove_volume.remove_volume,
    inspect_volume = inspect_volume.inspect_volume,
    prune_volumes = prune_volumes.prune_volumes,
  }
end

return Shared
