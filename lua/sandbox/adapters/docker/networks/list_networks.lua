---@module 'sandbox.adapters.docker.networks.list_networks'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.networks.list_networks`

return require("sandbox.adapters.cli.networks.list_networks").new("docker")
