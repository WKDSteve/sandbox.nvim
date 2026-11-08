---@module 'sandbox.adapters.nerdctl.images.prune_images'
--- Nerdctl Adapter: shared with the other docker-CLI engines, see `sandbox.adapters.cli.images.prune_images`

return require("sandbox.adapters.cli.images.prune_images").new("nerdctl")
