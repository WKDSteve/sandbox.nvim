---@module 'sandbox.core.usecases.networks.create_network'
--- Use case: Create a new named network
--- @param engine table: must implement create_network(name)
--- @param name string
--- @param on_done? fun(...) Optional: run asynchronously and deliver the result here instead of returning it
--- @return boolean ok, string|nil err
return function(engine, name, on_done)
  return engine.create_network(name, on_done)
end
