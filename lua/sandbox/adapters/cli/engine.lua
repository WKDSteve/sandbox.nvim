---@module 'sandbox.adapters.cli.engine'
--- Engine Adapter Aggregator
---
--- Merges the resource sub-aggregators (containers, images, volumes,
--- networks, registry) wholesale into a full implementation of the
--- ContainerEngine port, rather than re-listing every field by hand -- a
--- new method only has to be added to the matching *_engine.lua to be
--- reachable through sandbox.get_engine(); a hand-copied field list would
--- silently drop it the moment someone forgot to update this file too.
---
--- Shared by every engine that speaks the docker CLI: `new(name)` builds the aggregate from the modules
--- `sandbox.adapters.<name>.*`, so an engine that overrides one verb is picked up without a copy of this file.

local Shared = {}

--- @param name string the engine's directory (`docker`, `podman`, `nerdctl`)
--- @return table
function Shared.new(name)
  local engine = "sandbox.adapters." .. name

  local containers = require(engine .. ".containers_engine")
  local images = require(engine .. ".images_engine")
  local volumes = require(engine .. ".volumes_engine")
  local networks = require(engine .. ".networks_engine")
  local registry = require(engine .. ".registry_engine")

  return vim.tbl_extend("force", {}, containers, images, volumes, networks, registry)
end

return Shared
