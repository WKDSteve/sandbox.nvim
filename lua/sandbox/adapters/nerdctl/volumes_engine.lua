---@module 'sandbox.adapters.nerdctl.volumes_engine'
--- Nerdctl Adapter aggregate: shared, see `sandbox.adapters.cli.volumes_engine`

return require("sandbox.adapters.cli.volumes_engine").new("nerdctl")
