---@module 'sandbox.adapters.podman.compose.up'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.compose.up`

return require("sandbox.adapters.cli.compose.up").new("podman")
