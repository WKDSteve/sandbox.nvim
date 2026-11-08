---@module 'sandbox.adapters.podman.networks.prune_networks'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.networks.prune_networks`

return require("sandbox.adapters.cli.networks.prune_networks").new("podman")
