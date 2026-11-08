---@module 'sandbox.adapters.podman.networks.connect_network'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.networks.connect_network`

return require("sandbox.adapters.cli.networks.connect_network").new("podman")
