---@module 'sandbox.adapters.docker.containers_engine'
--- Docker Adapter aggregate: shared, see `sandbox.adapters.cli.containers_engine`

return require("sandbox.adapters.cli.containers_engine").new("docker")
