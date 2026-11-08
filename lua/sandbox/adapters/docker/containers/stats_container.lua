---@module 'sandbox.adapters.docker.containers.stats_container'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.stats_container`

return require("sandbox.adapters.cli.containers.stats_container").new("docker")
