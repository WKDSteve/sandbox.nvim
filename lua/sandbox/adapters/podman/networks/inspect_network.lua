---@module 'sandbox.adapters.podman.networks.inspect_network'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.networks.inspect_network`

return require("sandbox.adapters.cli.networks.inspect_network").new("podman")
