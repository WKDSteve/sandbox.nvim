---@module 'sandbox.adapters.podman.containers.remove_container'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.remove_container`

return require("sandbox.adapters.cli.containers.remove_container").new("podman")
