---@module 'sandbox.adapters.nerdctl.containers.run_once'
--- Nerdctl Adapter: run a container once, attached (output, exit code, --rm)

local M = {}

--- @param opts Sandbox.RunOnceOpts
--- @param on_line? fun(stream: "stdout"|"stderr", line: string)
--- @param on_exit fun(result: Sandbox.RunOnceResult)
--- @return { cancel: fun() } handle
function M.run_once(opts, on_line, on_exit)
  return require("sandbox.util.run_once").run("nerdctl", opts, on_line, on_exit)
end

return M
