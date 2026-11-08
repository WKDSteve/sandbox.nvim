---@module 'sandbox.adapters.podman.volumes.inspect_volume'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.volumes.inspect_volume`

return require("sandbox.adapters.cli.volumes.inspect_volume").new("podman")
