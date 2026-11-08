---@module 'sandbox.adapters.podman.compose.logs'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.compose.logs`

return require("sandbox.adapters.cli.compose.logs").new("podman")
