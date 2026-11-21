---@module 'sandbox.core.usecases.images.list_images'
--- Lists all images available locally
--- @param engine table: must implement list_images()
--- @param on_done? fun(...) Passed straight through: when given, the adapter
---        runs asynchronously and delivers the same values to this callback.
--- @return table[]|nil images, string|nil err
return function(engine, on_done)
  return engine.list_images(on_done)
end
