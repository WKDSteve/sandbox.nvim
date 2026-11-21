---@module 'sandbox.core.usecases.volumes.create_volume'
--- Use case: Create a new named volume
--- @param engine table: must implement create_volume(name)
--- @param name string
--- @param on_done? fun(...) Optional: run asynchronously and deliver the result here instead of returning it
--- @return boolean ok, string|nil err
return function(engine, name, on_done)
  return engine.create_volume(name, on_done)
end
