---@module 'sandbox.core.usecases.registry.login'
--- Authenticate against a registry (password piped via stdin, never argv).
--- @param engine table
--- @param username string
--- @param password string
--- @param registry? string
--- @param on_done? fun(...) Optional: run asynchronously and deliver the result here instead of returning it
--- @return boolean ok
--- @return string|nil err
return function(engine, username, password, registry, on_done)
  return engine.login_registry(username, password, registry, on_done)
end
