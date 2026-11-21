---@module 'sandbox.core.usecases.volumes.list_volumes'
--- Use case: List all volumes
--- @param engine table: must implement list_volumes()
--- @param on_done? fun(...) Passed straight through: when given, the adapter
---        runs asynchronously and delivers the same values to this callback.
--- @return table[]|nil volumes, string|nil err
return function(engine, on_done)
  return engine.list_volumes(on_done)
end
