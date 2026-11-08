---@module 'sandbox.adapters.nerdctl.volumes.inspect_volume'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.volumes.inspect_volume`

return require("sandbox.adapters.cli.volumes.inspect_volume").new("nerdctl")
