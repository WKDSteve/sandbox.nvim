---@module 'sandbox.core.usecases.images.load_image'
--- Use case: Load (import) an image from a tarball on disk
--- @param engine table: must implement load_image(path)
--- @param path string
--- @param on_done? fun(...) Optional: run asynchronously and deliver the result here instead of returning it
--- @return boolean ok, string|nil err
return function(engine, path, on_done)
  return engine.load_image(path, on_done)
end
