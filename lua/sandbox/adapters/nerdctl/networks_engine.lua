---@module 'sandbox.adapters.nerdctl.networks_engine'
--- Nerdctl Adapter aggregate: shared, see `sandbox.adapters.cli.networks_engine`

return require("sandbox.adapters.cli.networks_engine").new("nerdctl")
