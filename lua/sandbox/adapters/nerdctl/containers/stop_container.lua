---@module 'sandbox.adapters.nerdctl.containers.stop_container'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.stop_container`

return require("sandbox.adapters.cli.containers.stop_container").new("nerdctl")
