---@module 'sandbox.adapters.podman.containers.run_once'
--- Podman Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.run_once`

return require("sandbox.adapters.cli.containers.run_once").new("podman")
