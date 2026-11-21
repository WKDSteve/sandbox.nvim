---@module 'sandbox.core.usecases.containers.rename_container'
--- Use case: Rename a container
--- @param engine table: must implement rename_container(container_id, new_name)
--- @param container_id string
--- @param new_name string
--- @param on_done? fun(...) Passed straight through: when given, the adapter
---        runs asynchronously and delivers the same values to this callback.
--- @return boolean ok, string|nil err
return function(engine, container_id, new_name, on_done)
  return engine.rename_container(container_id, new_name, on_done)
end
