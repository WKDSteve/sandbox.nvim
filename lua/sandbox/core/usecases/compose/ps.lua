---@module 'sandbox.core.usecases.compose.ps'
--- Use case: List services in a compose project
--- @param engine table: must implement ps(file)
--- @param file string
--- @param on_done? fun(...) Optional: run asynchronously and deliver the result here instead of returning it
--- @return string[]|nil lines, string|nil err
return function(engine, file, on_done)
  return engine.ps(file, on_done)
end
