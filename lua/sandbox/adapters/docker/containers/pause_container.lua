---@module 'sandbox.adapters.docker.containers.pause_container'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.pause_container`

return require("sandbox.adapters.cli.containers.pause_container").new("docker")
