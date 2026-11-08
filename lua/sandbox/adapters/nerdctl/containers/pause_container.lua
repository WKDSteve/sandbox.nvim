---@module 'sandbox.adapters.nerdctl.containers.pause_container'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.pause_container`

return require("sandbox.adapters.cli.containers.pause_container").new("nerdctl")
