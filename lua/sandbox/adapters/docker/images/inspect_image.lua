---@module 'sandbox.adapters.docker.images.inspect_image'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.images.inspect_image`

return require("sandbox.adapters.cli.images.inspect_image").new("docker")
