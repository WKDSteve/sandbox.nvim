---@module 'sandbox.adapters.podman.containers.run_container'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.run_container`

return require("sandbox.adapters.cli.containers.run_container").new("podman")
