---@module 'sandbox.adapters.podman.containers.pause_container'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.pause_container`

return require("sandbox.adapters.cli.containers.pause_container").new("podman")
