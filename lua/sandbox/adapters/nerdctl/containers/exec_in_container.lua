---@module 'sandbox.adapters.nerdctl.containers.exec_in_container'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.exec_in_container`

return require("sandbox.adapters.cli.containers.exec_in_container").new("nerdctl")
