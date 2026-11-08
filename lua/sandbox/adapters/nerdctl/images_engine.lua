---@module 'sandbox.adapters.nerdctl.images_engine'
--- Nerdctl Adapter aggregate: shared, see `sandbox.adapters.cli.images_engine`

return require("sandbox.adapters.cli.images_engine").new("nerdctl")
