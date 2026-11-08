---@module 'sandbox.adapters.podman.containers.cp_container'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.cp_container`

return require("sandbox.adapters.cli.containers.cp_container").new("podman")
