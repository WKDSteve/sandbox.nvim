---@module 'sandbox.adapters.podman.volumes.prune_volumes'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.volumes.prune_volumes`

return require("sandbox.adapters.cli.volumes.prune_volumes").new("podman")
