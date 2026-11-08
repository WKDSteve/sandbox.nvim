---@module 'sandbox.adapters.podman.volumes.list_volumes'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.volumes.list_volumes`

return require("sandbox.adapters.cli.volumes.list_volumes").new("podman")
