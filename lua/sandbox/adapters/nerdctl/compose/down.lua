---@module 'sandbox.adapters.nerdctl.compose.down'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.compose.down`

return require("sandbox.adapters.cli.compose.down").new("nerdctl")
