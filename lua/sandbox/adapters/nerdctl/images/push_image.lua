---@module 'sandbox.adapters.nerdctl.images.push_image'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.images.push_image`

return require("sandbox.adapters.cli.images.push_image").new("nerdctl")
