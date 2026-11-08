---@module 'sandbox.adapters.docker.registry_engine'
--- Docker Adapter aggregate: shared, see `sandbox.adapters.cli.registry_engine`

return require("sandbox.adapters.cli.registry_engine").new("docker")
