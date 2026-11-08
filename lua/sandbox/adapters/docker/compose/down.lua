---@module 'sandbox.adapters.docker.compose.down'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.compose.down`

return require("sandbox.adapters.cli.compose.down").new("docker")
