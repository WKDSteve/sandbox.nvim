---@module 'sandbox.adapters.podman.engine'
--- Podman Adapter aggregate: shared, see `sandbox.adapters.cli.engine`

return require("sandbox.adapters.cli.engine").new("podman")
