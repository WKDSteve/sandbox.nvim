---@module 'sandbox.adapters.podman.images_engine'
--- Podman Adapter aggregate: shared, see `sandbox.adapters.cli.images_engine`

return require("sandbox.adapters.cli.images_engine").new("podman")
