---@module 'sandbox.adapters.nerdctl.registry.login'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.registry.login`

return require("sandbox.adapters.cli.registry.login").new("nerdctl")
