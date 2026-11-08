---@module 'sandbox.adapters.podman.images.remove_image'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.images.remove_image`

return require("sandbox.adapters.cli.images.remove_image").new("podman")
