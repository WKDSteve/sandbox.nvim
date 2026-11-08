---@module 'sandbox.adapters.nerdctl.images.history_image'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.images.history_image`

return require("sandbox.adapters.cli.images.history_image").new("nerdctl")
