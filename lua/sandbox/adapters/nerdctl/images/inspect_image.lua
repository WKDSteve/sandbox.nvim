---@module 'sandbox.adapters.nerdctl.images.inspect_image'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.images.inspect_image`

return require("sandbox.adapters.cli.images.inspect_image").new("nerdctl")
