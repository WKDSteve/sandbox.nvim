---@module 'sandbox.adapters.nerdctl.networks.connect_network'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.networks.connect_network`

return require("sandbox.adapters.cli.networks.connect_network").new("nerdctl")
