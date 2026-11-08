---@module 'sandbox.adapters.docker.volumes.remove_volume'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.volumes.remove_volume`

return require("sandbox.adapters.cli.volumes.remove_volume").new("docker")
