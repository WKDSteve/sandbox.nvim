---@module 'sandbox.adapters.docker.containers.prune_containers'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.prune_containers`

return require("sandbox.adapters.cli.containers.prune_containers").new("docker")
