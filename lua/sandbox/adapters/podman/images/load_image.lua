---@module 'sandbox.adapters.podman.images.load_image'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.images.load_image`

return require("sandbox.adapters.cli.images.load_image").new("podman")
