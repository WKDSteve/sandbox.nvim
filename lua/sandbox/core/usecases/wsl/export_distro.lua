---@module 'sandbox.core.usecases.wsl.export_distro'

---@param engine WslEngine
---@param name string
---@param path string
---@param on_done? fun(...) Optional: run asynchronously and deliver the result here instead of returning it
---@return boolean ok
---@return string|nil err
return function(engine, name, path, on_done)
  return engine.export_distro(name, path, on_done)
end
