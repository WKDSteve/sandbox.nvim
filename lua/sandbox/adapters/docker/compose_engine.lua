---@module 'sandbox.adapters.docker.compose_engine'
--- Docker Adapter aggregate: shared, see `sandbox.adapters.cli.compose_engine`

return require("sandbox.adapters.cli.compose_engine").new("docker")
