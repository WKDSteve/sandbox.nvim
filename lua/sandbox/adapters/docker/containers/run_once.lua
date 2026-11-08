---@module 'sandbox.adapters.docker.containers.run_once'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.run_once`

return require("sandbox.adapters.cli.containers.run_once").new("docker")
