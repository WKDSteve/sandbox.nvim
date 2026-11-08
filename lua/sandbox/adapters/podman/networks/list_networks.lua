---@module 'sandbox.adapters.podman.networks.list_networks'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.networks.list_networks`

return require("sandbox.adapters.cli.networks.list_networks").new("podman")
