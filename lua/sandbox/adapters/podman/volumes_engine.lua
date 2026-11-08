---@module 'sandbox.adapters.podman.volumes_engine'
--- Podman Adapter aggregate: shared, see `sandbox.adapters.cli.volumes_engine`

return require("sandbox.adapters.cli.volumes_engine").new("podman")
