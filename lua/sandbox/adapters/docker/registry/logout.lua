---@module 'sandbox.adapters.docker.registry.logout'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.registry.logout`

return require("sandbox.adapters.cli.registry.logout").new("docker")
