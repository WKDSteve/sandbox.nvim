---@module 'sandbox.adapters.nerdctl.compose_engine'
--- Nerdctl Adapter aggregate: shared, see `sandbox.adapters.cli.compose_engine`

return require("sandbox.adapters.cli.compose_engine").new("nerdctl")
