---@module 'sandbox.adapters.docker.engine'
--- Docker Adapter aggregate: shared, see `sandbox.adapters.cli.engine`

return require("sandbox.adapters.cli.engine").new("docker")
