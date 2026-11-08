---@module 'sandbox.adapters.nerdctl.containers.restart_container'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.restart_container`

return require("sandbox.adapters.cli.containers.restart_container").new("nerdctl")
