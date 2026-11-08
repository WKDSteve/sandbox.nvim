---@module 'sandbox.adapters.podman.containers.kill_container'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.kill_container`

return require("sandbox.adapters.cli.containers.kill_container").new("podman")
