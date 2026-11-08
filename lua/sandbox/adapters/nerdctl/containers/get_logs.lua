---@module 'sandbox.adapters.nerdctl.containers.get_logs'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.get_logs`

return require("sandbox.adapters.cli.containers.get_logs").new("nerdctl")
