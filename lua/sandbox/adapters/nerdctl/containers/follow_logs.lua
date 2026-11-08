---@module 'sandbox.adapters.nerdctl.containers.follow_logs'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.follow_logs`

return require("sandbox.adapters.cli.containers.follow_logs").new("nerdctl")
