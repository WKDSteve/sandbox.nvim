---@module 'sandbox.adapters.podman.images.tag_image'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.images.tag_image`

return require("sandbox.adapters.cli.images.tag_image").new("podman")
