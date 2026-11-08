---@module 'sandbox.adapters.podman.containers.rename_container'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.rename_container`

return require("sandbox.adapters.cli.containers.rename_container").new("podman")
