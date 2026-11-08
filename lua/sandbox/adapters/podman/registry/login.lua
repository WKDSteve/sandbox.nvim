---@module 'sandbox.adapters.podman.registry.login'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.registry.login`

return require("sandbox.adapters.cli.registry.login").new("podman")
