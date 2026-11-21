---@module 'sandbox.core.usecases.registry.logout'
--- Log out of a registry.
--- @param engine table
--- @param registry? string
--- @param on_done? fun(...) Passed straight through: when given, the adapter
---        runs asynchronously and delivers the same values to this callback.
--- @return boolean ok
--- @return string|nil err
return function(engine, registry, on_done)
  return engine.logout_registry(registry, on_done)
end
