---@module 'sandbox.adapters.docker.containers.remove_container'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.remove_container`

return require("sandbox.adapters.cli.containers.remove_container").new("docker")
