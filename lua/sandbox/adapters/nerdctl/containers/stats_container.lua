---@module 'sandbox.adapters.nerdctl.containers.stats_container'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.stats_container`

return require("sandbox.adapters.cli.containers.stats_container").new("nerdctl")
