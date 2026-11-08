---@module 'sandbox.adapters.nerdctl.compose.restart'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.compose.restart`

return require("sandbox.adapters.cli.compose.restart").new("nerdctl")
