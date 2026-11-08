---@module 'sandbox.adapters.docker.volumes.list_volumes'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.volumes.list_volumes`

return require("sandbox.adapters.cli.volumes.list_volumes").new("docker")
