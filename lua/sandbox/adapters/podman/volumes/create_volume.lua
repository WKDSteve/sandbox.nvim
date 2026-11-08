---@module 'sandbox.adapters.podman.volumes.create_volume'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.volumes.create_volume`

return require("sandbox.adapters.cli.volumes.create_volume").new("podman")
