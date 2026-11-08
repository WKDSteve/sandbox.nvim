---@module 'sandbox.adapters.nerdctl.images.save_image'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.images.save_image`

return require("sandbox.adapters.cli.images.save_image").new("nerdctl")
