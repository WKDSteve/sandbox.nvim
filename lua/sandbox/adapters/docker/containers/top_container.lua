---@module 'sandbox.adapters.docker.containers.top_container'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.top_container`

return require("sandbox.adapters.cli.containers.top_container").new("docker")
