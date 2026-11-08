---@module 'sandbox.adapters.docker.containers.list_containers'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.list_containers`

return require("sandbox.adapters.cli.containers.list_containers").new("docker")
