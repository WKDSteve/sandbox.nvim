---@module 'sandbox.adapters.nerdctl.engine'
--- Nerdctl Adapter aggregate: shared, see `sandbox.adapters.cli.engine`

return require("sandbox.adapters.cli.engine").new("nerdctl")
