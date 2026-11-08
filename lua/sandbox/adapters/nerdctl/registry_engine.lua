---@module 'sandbox.adapters.nerdctl.registry_engine'
--- Nerdctl Adapter aggregate: shared, see `sandbox.adapters.cli.registry_engine`

return require("sandbox.adapters.cli.registry_engine").new("nerdctl")
