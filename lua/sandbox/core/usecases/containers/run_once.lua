---@module 'sandbox.core.usecases.containers.run_once'
--- Use case: run a container once, attached -- stream its output, report the exit code, remove it
--- afterwards. Headless: no window, no notification. A timeout or `cancel()` stops the container,
--- not only the CLI in front of it.
--- @param engine table: must implement run_once(opts, on_line, on_exit)
--- @param opts Sandbox.RunOnceOpts
--- @param on_line? fun(stream: "stdout"|"stderr", line: string)
--- @param on_exit fun(result: Sandbox.RunOnceResult)
--- @return { cancel: fun() } handle
return function(engine, opts, on_line, on_exit)
  return engine.run_once(opts, on_line, on_exit)
end
