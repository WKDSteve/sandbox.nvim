---@module 'sandbox.adapters.nerdctl.images.list_images'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.images.list_images`

return require("sandbox.adapters.cli.images.list_images").new("nerdctl")
