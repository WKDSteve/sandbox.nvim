---@module 'sandbox.adapters.podman.registry.logout'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.registry.logout`

return require("sandbox.adapters.cli.registry.logout").new("podman")
