---@module 'sandbox.adapters.docker.containers.rename_container'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.rename_container`

return require("sandbox.adapters.cli.containers.rename_container").new("docker")
