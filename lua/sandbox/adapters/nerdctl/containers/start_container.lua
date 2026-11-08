---@module 'sandbox.adapters.nerdctl.containers.start_container'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.start_container`

return require("sandbox.adapters.cli.containers.start_container").new("nerdctl")
