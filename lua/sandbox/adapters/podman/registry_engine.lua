---@module 'sandbox.adapters.podman.registry_engine'
--- Podman Adapter aggregate: shared, see `sandbox.adapters.cli.registry_engine`

return require("sandbox.adapters.cli.registry_engine").new("podman")
