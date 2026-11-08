---@module 'sandbox.adapters.podman.networks.remove_network'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.networks.remove_network`

return require("sandbox.adapters.cli.networks.remove_network").new("podman")
