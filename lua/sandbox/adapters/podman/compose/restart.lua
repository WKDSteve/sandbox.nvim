---@module 'sandbox.adapters.podman.compose.restart'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.compose.restart`

return require("sandbox.adapters.cli.compose.restart").new("podman")
