---@module 'sandbox.adapters.docker.compose.ps'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.compose.ps`

return require("sandbox.adapters.cli.compose.ps").new("docker")
