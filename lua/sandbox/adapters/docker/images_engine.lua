---@module 'sandbox.adapters.docker.images_engine'
--- Docker Adapter aggregate: shared, see `sandbox.adapters.cli.images_engine`

return require("sandbox.adapters.cli.images_engine").new("docker")
