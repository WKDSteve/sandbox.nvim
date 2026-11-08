---@module 'sandbox.adapters.podman.containers.restart_container'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.restart_container`

return require("sandbox.adapters.cli.containers.restart_container").new("podman")
