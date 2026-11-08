---@module 'sandbox.adapters.docker.containers.exec_in_container'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.exec_in_container`

return require("sandbox.adapters.cli.containers.exec_in_container").new("docker")
