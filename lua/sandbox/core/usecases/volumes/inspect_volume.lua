---@module 'sandbox.core.usecases.volumes.inspect_volume'
--- Use Case: Inspect detailed metadata of a volume
--- @param engine table: must implement inspect_volume(name)
--- @param name string
--- @param on_done? fun(...) Optional: run asynchronously and deliver the result here instead of returning it
--- @return table|string[]
return function(engine, name, on_done)
  return engine.inspect_volume(name, on_done)
end
