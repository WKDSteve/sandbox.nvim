---@module 'sandbox.adapters.nerdctl.containers.inspect_container'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.inspect_container`

return require("sandbox.adapters.cli.containers.inspect_container").new("nerdctl")
