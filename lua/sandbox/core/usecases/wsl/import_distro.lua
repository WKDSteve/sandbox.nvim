---@module 'sandbox.core.usecases.wsl.import_distro'

---@param engine WslEngine
---@param name string
---@param install_path string
---@param tar_path string
---@param on_done? fun(...) Optional: run asynchronously and deliver the result here instead of returning it
---@return boolean ok
---@return string|nil err
return function(engine, name, install_path, tar_path, on_done)
  return engine.import_distro(name, install_path, tar_path, on_done)
end
