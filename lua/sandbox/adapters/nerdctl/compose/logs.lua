---@module 'sandbox.adapters.nerdctl.compose.logs'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.compose.logs`

return require("sandbox.adapters.cli.compose.logs").new("nerdctl")
