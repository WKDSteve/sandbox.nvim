---@module 'sandbox.core.usecases.wsl.start_distro'

---@param engine WslEngine
---@param name string
---@param on_done? fun(...) Passed straight through: when given, the adapter
---       runs asynchronously and delivers the same values to this callback.
---@return boolean ok
---@return string|nil err
return function(engine, name, on_done)
  return engine.start_distro(name, on_done)
end
