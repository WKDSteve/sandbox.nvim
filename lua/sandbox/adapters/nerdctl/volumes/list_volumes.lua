---@module 'sandbox.adapters.nerdctl.volumes.list_volumes'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.volumes.list_volumes`

return require("sandbox.adapters.cli.volumes.list_volumes").new("nerdctl")
