---@module 'sandbox.adapters.podman.images.push_image'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.images.push_image`

return require("sandbox.adapters.cli.images.push_image").new("podman")
