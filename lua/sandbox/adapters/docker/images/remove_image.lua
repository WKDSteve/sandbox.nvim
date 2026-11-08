---@module 'sandbox.adapters.docker.images.remove_image'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.images.remove_image`

return require("sandbox.adapters.cli.images.remove_image").new("docker")
