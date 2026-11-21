---@module 'sandbox.core.usecases.images.save_image'
--- Use case: Save (export) an image to a tarball on disk
--- @param engine table: must implement save_image(image, path)
--- @param image string
--- @param path string
--- @param on_done? fun(...) Optional: run asynchronously and deliver the result here instead of returning it
--- @return boolean ok, string|nil err
return function(engine, image, path, on_done)
  return engine.save_image(image, path, on_done)
end
