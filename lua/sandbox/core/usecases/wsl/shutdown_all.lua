---@module 'sandbox.core.usecases.wsl.shutdown_all'

---@param engine WslEngine
---@param on_done? fun(...) Optional: run asynchronously and deliver the result here instead of returning it
---@return boolean ok
---@return string|nil err
return function(engine, on_done)
  return engine.shutdown_all(on_done)
end
