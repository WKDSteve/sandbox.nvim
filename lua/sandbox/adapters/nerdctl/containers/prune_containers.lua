---@module 'sandbox.adapters.nerdctl.containers.prune_containers'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.prune_containers`

return require("sandbox.adapters.cli.containers.prune_containers").new("nerdctl")
