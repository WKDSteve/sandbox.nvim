---@module 'sandbox.adapters.podman.containers.follow_logs'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.follow_logs`

return require("sandbox.adapters.cli.containers.follow_logs").new("podman")
