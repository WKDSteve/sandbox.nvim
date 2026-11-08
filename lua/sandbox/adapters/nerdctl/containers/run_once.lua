---@module 'sandbox.adapters.nerdctl.containers.run_once'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.run_once`

return require("sandbox.adapters.cli.containers.run_once").new("nerdctl")
