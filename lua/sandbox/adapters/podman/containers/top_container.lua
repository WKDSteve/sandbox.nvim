---@module 'sandbox.adapters.podman.containers.top_container'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.top_container`

return require("sandbox.adapters.cli.containers.top_container").new("podman")
