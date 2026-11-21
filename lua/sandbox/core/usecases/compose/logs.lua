---@module 'sandbox.core.usecases.compose.logs'
--- Use case: Show logs for a compose project
--- @param engine table: must implement logs(file)
--- @param file string
--- @param on_done? fun(...) Optional: run asynchronously and deliver the result here instead of returning it
--- @return string[]|nil lines, string|nil err
return function(engine, file, on_done)
  return engine.logs(file, on_done)
end
