---@module 'sandbox.adapters.docker.networks.inspect_network'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.networks.inspect_network`

return require("sandbox.adapters.cli.networks.inspect_network").new("docker")
