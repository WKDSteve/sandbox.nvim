---@module 'sandbox.adapters.docker.images.push_image'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.images.push_image`

return require("sandbox.adapters.cli.images.push_image").new("docker")
