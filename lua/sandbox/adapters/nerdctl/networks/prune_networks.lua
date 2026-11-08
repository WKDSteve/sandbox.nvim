---@module 'sandbox.adapters.nerdctl.networks.prune_networks'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.networks.prune_networks`

return require("sandbox.adapters.cli.networks.prune_networks").new("nerdctl")
