---@module 'sandbox.adapters.podman.networks_engine'
--- Podman Adapter aggregate: shared, see `sandbox.adapters.cli.networks_engine`

return require("sandbox.adapters.cli.networks_engine").new("podman")
