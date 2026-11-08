---@module 'sandbox.adapters.podman.compose.ps'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.compose.ps`

return require("sandbox.adapters.cli.compose.ps").new("podman")
