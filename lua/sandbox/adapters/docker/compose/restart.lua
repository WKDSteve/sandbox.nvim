---@module 'sandbox.adapters.docker.compose.restart'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.compose.restart`

return require("sandbox.adapters.cli.compose.restart").new("docker")
