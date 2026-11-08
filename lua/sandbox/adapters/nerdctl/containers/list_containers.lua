---@module 'sandbox.adapters.nerdctl.containers.list_containers'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.list_containers`

return require("sandbox.adapters.cli.containers.list_containers").new("nerdctl")
