---@module 'sandbox.adapters.podman.compose.down'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.compose.down`

return require("sandbox.adapters.cli.compose.down").new("podman")
