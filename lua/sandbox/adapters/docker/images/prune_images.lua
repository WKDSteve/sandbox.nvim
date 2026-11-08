---@module 'sandbox.adapters.docker.images.prune_images'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.images.prune_images`

return require("sandbox.adapters.cli.images.prune_images").new("docker")
