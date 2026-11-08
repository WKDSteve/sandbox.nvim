---@module 'sandbox.adapters.docker.containers.start_container'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.start_container`

return require("sandbox.adapters.cli.containers.start_container").new("docker")
