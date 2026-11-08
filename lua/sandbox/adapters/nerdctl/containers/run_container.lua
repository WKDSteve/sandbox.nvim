---@module 'sandbox.adapters.nerdctl.containers.run_container'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.run_container`

return require("sandbox.adapters.cli.containers.run_container").new("nerdctl")
