---@module 'sandbox.core.usecases.images.tag_image'
--- Use case: Tag a local image
--- @param engine table: must implement tag_image(source, target)
--- @param source string
--- @param target string
--- @param on_done? fun(...) Optional: run asynchronously and deliver the result here instead of returning it
--- @return boolean ok, string|nil err
return function(engine, source, target, on_done)
  return engine.tag_image(source, target, on_done)
end
