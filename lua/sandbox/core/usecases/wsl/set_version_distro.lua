---@module 'sandbox.core.usecases.wsl.set_version_distro'

---@param engine WslEngine
---@param name string
---@param version integer 1 or 2
---@param on_done? fun(...) Optional: run asynchronously and deliver the result here instead of returning it
---@return boolean ok
---@return string|nil err
return function(engine, name, version, on_done)
  return engine.set_version_distro(name, version, on_done)
end
