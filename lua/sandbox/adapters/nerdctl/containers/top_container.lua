---@module 'sandbox.adapters.nerdctl.containers.top_container'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.top_container`

return require("sandbox.adapters.cli.containers.top_container").new("nerdctl")
