---@module 'sandbox.adapters.nerdctl.containers.remove_container'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.remove_container`

return require("sandbox.adapters.cli.containers.remove_container").new("nerdctl")
