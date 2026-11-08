---@module 'sandbox.adapters.docker.containers.restart_container'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.restart_container`

return require("sandbox.adapters.cli.containers.restart_container").new("docker")
