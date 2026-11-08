---@module 'sandbox.adapters.nerdctl.containers_engine'
--- Nerdctl Adapter aggregate: shared, see `sandbox.adapters.cli.containers_engine`

return require("sandbox.adapters.cli.containers_engine").new("nerdctl")
