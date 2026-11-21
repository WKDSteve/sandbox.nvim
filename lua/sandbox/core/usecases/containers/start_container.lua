---@module 'sandbox.core.usecases.containers.start_container'
--- Use case: Start a container
--- @param engine table: must implement start_container(container_id)
--- @param container_id string: ID of the container to start
--- @param on_done? fun(...) Passed straight through: when given, the adapter
---        runs asynchronously and delivers the same values to this callback.
--- @return boolean ok, string|nil err
return function(engine, container_id, on_done)
  return engine.start_container(container_id, on_done)
end
