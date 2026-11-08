---@module 'sandbox.adapters.nerdctl.networks.list_networks'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.networks.list_networks`

return require("sandbox.adapters.cli.networks.list_networks").new("nerdctl")
