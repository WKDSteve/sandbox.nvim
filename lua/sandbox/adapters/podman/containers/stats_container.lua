---@module 'sandbox.adapters.podman.containers.stats_container'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.stats_container`

return require("sandbox.adapters.cli.containers.stats_container").new("podman")
