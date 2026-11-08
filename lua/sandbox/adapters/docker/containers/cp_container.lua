---@module 'sandbox.adapters.docker.containers.cp_container'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.cp_container`

return require("sandbox.adapters.cli.containers.cp_container").new("docker")
