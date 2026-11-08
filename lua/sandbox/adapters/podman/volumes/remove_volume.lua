---@module 'sandbox.adapters.podman.volumes.remove_volume'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.volumes.remove_volume`

return require("sandbox.adapters.cli.volumes.remove_volume").new("podman")
