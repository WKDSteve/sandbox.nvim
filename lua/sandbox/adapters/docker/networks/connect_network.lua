---@module 'sandbox.adapters.docker.networks.connect_network'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.networks.connect_network`

return require("sandbox.adapters.cli.networks.connect_network").new("docker")
