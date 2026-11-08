---@module 'sandbox.adapters.docker.networks.create_network'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.networks.create_network`

return require("sandbox.adapters.cli.networks.create_network").new("docker")
