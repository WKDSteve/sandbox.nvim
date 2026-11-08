---@module 'sandbox.adapters.cli.images_engine'
--- Engine Image Adapter Aggregator
---
--- Combines all image operations into a unified interface
--- for the ContainerEngine port (specific to Engine).
---
--- Shared by every engine that speaks the docker CLI: `new(name)` builds the aggregate from the modules
--- `sandbox.adapters.<name>.*`, so an engine that overrides one verb is picked up without a copy of this file.

local Shared = {}

--- @param name string the engine's directory (`docker`, `podman`, `nerdctl`)
--- @return table
function Shared.new(name)
  local engine = "sandbox.adapters." .. name

  local list_images = require(engine .. ".images.list_images")
  local pull_image = require(engine .. ".images.pull_image")
  local push_image = require(engine .. ".images.push_image")
  local remove_image = require(engine .. ".images.remove_image")
  local prune_images = require(engine .. ".images.prune_images")
  local tag_image = require(engine .. ".images.tag_image")
  local save_image = require(engine .. ".images.save_image")
  local load_image = require(engine .. ".images.load_image")
  local history_image = require(engine .. ".images.history_image")
  local inspect_image = require(engine .. ".images.inspect_image")

  --- Image operations exposed by the Engine adapter
  return {
    list_images = list_images.list_images,
    pull_image = pull_image.pull_image,
    push_image = push_image.push_image,
    remove_image = remove_image.remove_image,
    prune_images = prune_images.prune_images,
    tag_image = tag_image.tag_image,
    save_image = save_image.save_image,
    load_image = load_image.load_image,
    history_image = history_image.history_image,
    inspect_image = inspect_image.inspect_image,
  }
end

return Shared
