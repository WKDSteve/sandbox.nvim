---@module 'sandbox.adapters.nerdctl.volumes.create_volume'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.volumes.create_volume`

return require("sandbox.adapters.cli.volumes.create_volume").new("nerdctl")
