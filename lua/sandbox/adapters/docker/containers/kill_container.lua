---@module 'sandbox.adapters.docker.containers.kill_container'
--- Docker Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.containers.kill_container`

return require("sandbox.adapters.cli.containers.kill_container").new("docker")
