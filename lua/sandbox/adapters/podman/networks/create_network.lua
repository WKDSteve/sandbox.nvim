---@module 'sandbox.adapters.podman.networks.create_network'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.networks.create_network`

return require("sandbox.adapters.cli.networks.create_network").new("podman")
