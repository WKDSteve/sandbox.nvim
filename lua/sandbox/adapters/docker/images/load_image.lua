---@module 'sandbox.adapters.docker.images.load_image'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.images.load_image`

return require("sandbox.adapters.cli.images.load_image").new("docker")
