---@module 'sandbox.core.usecases.wsl.set_default_distro'

---@param engine WslEngine
---@param name string
---@param on_done? fun(...) Optional: run asynchronously and deliver the result here instead of returning it
---@return boolean ok
---@return string|nil err
return function(engine, name, on_done)
  return engine.set_default_distro(name, on_done)
end
