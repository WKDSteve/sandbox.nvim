---@module 'sandbox.adapters.docker.networks.prune_networks'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.networks.prune_networks`

return require("sandbox.adapters.cli.networks.prune_networks").new("docker")
