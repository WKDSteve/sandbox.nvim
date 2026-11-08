---@module 'sandbox.adapters.podman.images.pull_image'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.images.pull_image`

return require("sandbox.adapters.cli.images.pull_image").new("podman")
