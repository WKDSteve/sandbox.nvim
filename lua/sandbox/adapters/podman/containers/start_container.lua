---@module 'sandbox.adapters.podman.containers.start_container'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.start_container`

return require("sandbox.adapters.cli.containers.start_container").new("podman")
