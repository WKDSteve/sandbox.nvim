---@module 'sandbox.adapters.nerdctl.volumes.remove_volume'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.volumes.remove_volume`

return require("sandbox.adapters.cli.volumes.remove_volume").new("nerdctl")
