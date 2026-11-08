---@module 'sandbox.adapters.nerdctl.registry.logout'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.registry.logout`

return require("sandbox.adapters.cli.registry.logout").new("nerdctl")
