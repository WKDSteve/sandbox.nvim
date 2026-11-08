---@module 'sandbox.adapters.podman.images.prune_images'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.images.prune_images`

return require("sandbox.adapters.cli.images.prune_images").new("podman")
