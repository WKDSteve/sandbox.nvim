---@module 'sandbox.core.usecases.networks.list_networks'
--- Use case: List all networks
--- @param engine table: must implement list_networks()
--- @param on_done? fun(...) Passed straight through: when given, the adapter
---        runs asynchronously and delivers the same values to this callback.
--- @return table[]|nil networks, string|nil err
return function(engine, on_done)
  return engine.list_networks(on_done)
end
