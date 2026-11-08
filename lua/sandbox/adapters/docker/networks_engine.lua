---@module 'sandbox.adapters.docker.networks_engine'
--- Docker Adapter aggregate: shared, see `sandbox.adapters.cli.networks_engine`

return require("sandbox.adapters.cli.networks_engine").new("docker")
