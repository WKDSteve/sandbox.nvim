---@module 'sandbox.adapters.nerdctl.volumes.prune_volumes'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.volumes.prune_volumes`

return require("sandbox.adapters.cli.volumes.prune_volumes").new("nerdctl")
