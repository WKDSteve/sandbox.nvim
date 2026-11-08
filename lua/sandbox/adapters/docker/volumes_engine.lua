---@module 'sandbox.adapters.docker.volumes_engine'
--- Docker Adapter aggregate: shared, see `sandbox.adapters.cli.volumes_engine`

return require("sandbox.adapters.cli.volumes_engine").new("docker")
