---@module 'sandbox.adapters.docker.networks.remove_network'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.networks.remove_network`

return require("sandbox.adapters.cli.networks.remove_network").new("docker")
