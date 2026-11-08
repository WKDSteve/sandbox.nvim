---@module 'sandbox.adapters.docker.registry.login'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.registry.login`

return require("sandbox.adapters.cli.registry.login").new("docker")
