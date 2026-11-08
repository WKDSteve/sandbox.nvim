---@module 'sandbox.adapters.docker.containers.follow_logs'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.follow_logs`

return require("sandbox.adapters.cli.containers.follow_logs").new("docker")
