---@module 'sandbox.core.usecases.images.inspect_image'
--- Use Case: Inspect detailed metadata of an image
--- @param engine table: must implement inspect_image(image)
--- @param image string
--- @param on_done? fun(...) Optional: run asynchronously and deliver the result here instead of returning it
--- @return table|string[]
return function(engine, image, on_done)
  return engine.inspect_image(image, on_done)
end
