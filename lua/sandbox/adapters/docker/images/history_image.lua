---@module 'sandbox.adapters.docker.images.history_image'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.images.history_image`

return require("sandbox.adapters.cli.images.history_image").new("docker")
