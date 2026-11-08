---@module 'sandbox.adapters.docker.volumes.prune_volumes'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.volumes.prune_volumes`

return require("sandbox.adapters.cli.volumes.prune_volumes").new("docker")
