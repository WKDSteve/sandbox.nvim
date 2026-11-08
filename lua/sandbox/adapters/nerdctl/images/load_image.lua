---@module 'sandbox.adapters.nerdctl.images.load_image'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.images.load_image`

return require("sandbox.adapters.cli.images.load_image").new("nerdctl")
