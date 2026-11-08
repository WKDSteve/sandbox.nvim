---@module 'sandbox.adapters.nerdctl.networks.create_network'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.networks.create_network`

return require("sandbox.adapters.cli.networks.create_network").new("nerdctl")
