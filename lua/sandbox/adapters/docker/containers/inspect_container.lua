---@module 'sandbox.adapters.docker.containers.inspect_container'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.inspect_container`

return require("sandbox.adapters.cli.containers.inspect_container").new("docker")
