---@module 'sandbox.adapters.docker.images.save_image'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.images.save_image`

return require("sandbox.adapters.cli.images.save_image").new("docker")
