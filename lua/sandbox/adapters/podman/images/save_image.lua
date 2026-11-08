---@module 'sandbox.adapters.podman.images.save_image'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.images.save_image`

return require("sandbox.adapters.cli.images.save_image").new("podman")
