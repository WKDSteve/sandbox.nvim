---@module 'sandbox.core.usecases.wsl.list_distros'

---@param engine WslEngine
---@param on_done? fun(...) Passed straight through: when given, the adapter
---       runs asynchronously and delivers the same values to this callback.
---@return WslDistro[]|nil distros
---@return string|nil err
return function(engine, on_done)
  return engine.list_distros(on_done)
end
