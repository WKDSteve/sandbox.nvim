---@module 'sandbox.adapters.nerdctl.containers.rename_container'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.rename_container`

return require("sandbox.adapters.cli.containers.rename_container").new("nerdctl")
