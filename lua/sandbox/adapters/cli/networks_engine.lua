---@module 'sandbox.adapters.cli.networks_engine'
--- Engine Network Adapter Aggregator
---
--- Combines all network operations into a unified interface
--- for the ContainerEngine port (specific to Engine).
---
--- Shared by every engine that speaks the docker CLI: `new(name)` builds the aggregate from the modules
--- `sandbox.adapters.<name>.*`, so an engine that overrides one verb is picked up without a copy of this file.

local Shared = {}

--- @param name string the engine's directory (`docker`, `podman`, `nerdctl`)
--- @return table
function Shared.new(name)
  local engine = "sandbox.adapters." .. name

  local list_networks = require(engine .. ".networks.list_networks")
  local create_network = require(engine .. ".networks.create_network")
  local remove_network = require(engine .. ".networks.remove_network")
  local inspect_network = require(engine .. ".networks.inspect_network")
  local connect_network = require(engine .. ".networks.connect_network")
  local prune_networks = require(engine .. ".networks.prune_networks")

  --- Network operations exposed by the Engine adapter
  return {
    list_networks = list_networks.list_networks,
    create_network = create_network.create_network,
    remove_network = remove_network.remove_network,
    inspect_network = inspect_network.inspect_network,
    connect_network = connect_network.connect_network,
    disconnect_network = connect_network.disconnect_network,
    prune_networks = prune_networks.prune_networks,
  }
end

return Shared
