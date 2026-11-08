---@module 'sandbox.adapters.nerdctl.networks.remove_network'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.networks.remove_network`

return require("sandbox.adapters.cli.networks.remove_network").new("nerdctl")
