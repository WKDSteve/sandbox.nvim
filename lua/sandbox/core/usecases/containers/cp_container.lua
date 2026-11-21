---@module 'sandbox.core.usecases.containers.cp_container'
--- Use case: Copy a file or directory between the host and a container
--- @param engine table: must implement cp_container(src, dest)
--- @param src string
--- @param dest string
--- @param on_done? fun(...) Passed straight through: when given, the adapter
---        runs asynchronously and delivers the same values to this callback.
--- @return boolean ok, string|nil err
return function(engine, src, dest, on_done)
  return engine.cp_container(src, dest, on_done)
end
