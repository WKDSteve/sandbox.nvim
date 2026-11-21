---@module 'sandbox.core.usecases.networks.inspect_network'
--- Use Case: Inspect detailed metadata of a network
--- @param engine table: must implement inspect_network(name)
--- @param name string
--- @param on_done? fun(...) Optional: run asynchronously and deliver the result here instead of returning it
--- @return table|string[]
return function(engine, name, on_done)
  return engine.inspect_network(name, on_done)
end
