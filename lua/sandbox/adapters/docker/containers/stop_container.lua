---@module 'sandbox.adapters.docker.containers.stop_container'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.stop_container`

return require("sandbox.adapters.cli.containers.stop_container").new("docker")
