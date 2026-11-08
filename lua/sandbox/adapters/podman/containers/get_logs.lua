---@module 'sandbox.adapters.podman.containers.get_logs'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.get_logs`

return require("sandbox.adapters.cli.containers.get_logs").new("podman")
