---@module 'sandbox.adapters.nerdctl.images.tag_image'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.images.tag_image`

return require("sandbox.adapters.cli.images.tag_image").new("nerdctl")
