---@module 'sandbox.adapters.podman.containers.prune_containers'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.prune_containers`

return require("sandbox.adapters.cli.containers.prune_containers").new("podman")
