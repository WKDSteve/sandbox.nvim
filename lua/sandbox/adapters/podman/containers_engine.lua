---@module 'sandbox.adapters.podman.containers_engine'
--- Podman Adapter aggregate: shared, see `sandbox.adapters.cli.containers_engine`

return require("sandbox.adapters.cli.containers_engine").new("podman")
