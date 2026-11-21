---@module 'sandbox.core.usecases.networks.connect_network'
--- Use case: Connect a container to a network
--- @param engine table: must implement connect_network(network, container_id)
--- @param network string
--- @param container_id string
--- @param on_done? fun(...) Optional: run asynchronously and deliver the result here instead of returning it
--- @return boolean ok, string|nil err
return function(engine, network, container_id, on_done)
  return engine.connect_network(network, container_id, on_done)
end
