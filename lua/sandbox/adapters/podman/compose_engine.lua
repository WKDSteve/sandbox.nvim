---@module 'sandbox.adapters.podman.compose_engine'
--- Podman Adapter aggregate: shared, see `sandbox.adapters.cli.compose_engine`

return require("sandbox.adapters.cli.compose_engine").new("podman")
