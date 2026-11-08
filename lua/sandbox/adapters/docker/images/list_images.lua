---@module 'sandbox.adapters.docker.images.list_images'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.images.list_images`

return require("sandbox.adapters.cli.images.list_images").new("docker")
