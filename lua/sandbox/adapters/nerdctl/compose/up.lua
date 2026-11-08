---@module 'sandbox.adapters.nerdctl.compose.up'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.compose.up`

return require("sandbox.adapters.cli.compose.up").new("nerdctl")
