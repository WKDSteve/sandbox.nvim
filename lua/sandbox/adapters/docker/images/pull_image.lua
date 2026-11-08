---@module 'sandbox.adapters.docker.images.pull_image'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.images.pull_image`

return require("sandbox.adapters.cli.images.pull_image").new("docker")
