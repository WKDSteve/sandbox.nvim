---@module 'sandbox.adapters.docker.containers.run_container'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.run_container`

return require("sandbox.adapters.cli.containers.run_container").new("docker")
