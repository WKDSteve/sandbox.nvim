---@module 'sandbox.adapters.docker.volumes.inspect_volume'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.volumes.inspect_volume`

return require("sandbox.adapters.cli.volumes.inspect_volume").new("docker")
