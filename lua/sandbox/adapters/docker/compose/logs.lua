---@module 'sandbox.adapters.docker.compose.logs'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.compose.logs`

return require("sandbox.adapters.cli.compose.logs").new("docker")
