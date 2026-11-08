---@module 'sandbox.adapters.nerdctl.containers.kill_container'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.kill_container`

return require("sandbox.adapters.cli.containers.kill_container").new("nerdctl")
