---@module 'sandbox.adapters.docker.containers.get_logs'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.get_logs`

return require("sandbox.adapters.cli.containers.get_logs").new("docker")
