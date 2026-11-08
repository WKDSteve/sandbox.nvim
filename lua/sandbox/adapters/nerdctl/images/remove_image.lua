---@module 'sandbox.adapters.nerdctl.images.remove_image'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.images.remove_image`

return require("sandbox.adapters.cli.images.remove_image").new("nerdctl")
