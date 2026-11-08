---@module 'sandbox.adapters.nerdctl.networks.inspect_network'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.networks.inspect_network`

return require("sandbox.adapters.cli.networks.inspect_network").new("nerdctl")
