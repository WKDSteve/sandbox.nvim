---@module 'sandbox.adapters.nerdctl.containers.cp_container'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.cp_container`

return require("sandbox.adapters.cli.containers.cp_container").new("nerdctl")
