---@module 'sandbox.adapters.podman.containers.inspect_container'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.inspect_container`

return require("sandbox.adapters.cli.containers.inspect_container").new("podman")
