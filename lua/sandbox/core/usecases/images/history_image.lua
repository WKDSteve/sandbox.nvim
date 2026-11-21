---@module 'sandbox.core.usecases.images.history_image'
--- Use case: Show an image's layer history
--- @param engine table: must implement history_image(image)
--- @param image string
--- @param on_done? fun(...) Optional: run asynchronously and deliver the result here instead of returning it
--- @return string[]|nil lines, string|nil err
return function(engine, image, on_done)
  return engine.history_image(image, on_done)
end
