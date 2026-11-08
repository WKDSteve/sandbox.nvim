---@module 'sandbox.adapters.podman.images.inspect_image'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.images.inspect_image`

return require("sandbox.adapters.cli.images.inspect_image").new("podman")
