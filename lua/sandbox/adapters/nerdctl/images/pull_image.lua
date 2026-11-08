---@module 'sandbox.adapters.nerdctl.images.pull_image'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.images.pull_image`

return require("sandbox.adapters.cli.images.pull_image").new("nerdctl")
