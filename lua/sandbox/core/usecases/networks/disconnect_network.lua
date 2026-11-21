---@module 'sandbox.core.usecases.networks.disconnect_network'
--- Use case: Disconnect a container from a network
--- @param engine table: must implement disconnect_network(network, container_id)
--- @param network string
--- @param container_id string
--- @param on_done? fun(...) Optional: run asynchronously and deliver the result here instead of returning it
--- @return boolean ok, string|nil err
return function(engine, network, container_id, on_done)
  return engine.disconnect_network(network, container_id, on_done)
end
