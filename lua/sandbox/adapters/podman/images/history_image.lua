---@module 'sandbox.adapters.podman.images.history_image'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.images.history_image`

return require("sandbox.adapters.cli.images.history_image").new("podman")
