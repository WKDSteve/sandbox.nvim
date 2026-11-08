---@module 'sandbox.adapters.cli.containers.run_once'
--- CLI Adapter (docker, podman, nerdctl): run a container once, attached (output, exit code, --rm)
---
--- One definition for every engine that speaks the docker CLI: `new(bin)` returns the functions for
--- the binary `bin`. The per-engine module of the same name calls it
--- (`sandbox.adapters.<engine>.<group>.<verb>`).

local Shared = {}

--- @param bin string the engine's binary (`docker`, `podman`, `nerdctl`)
--- @return table the functions of this module
function Shared.new(bin)
  local M = {}

  --- @param opts Sandbox.RunOnceOpts
  --- @param on_line? fun(stream: "stdout"|"stderr", line: string)
  --- @param on_exit fun(result: Sandbox.RunOnceResult)
  --- @return { cancel: fun() } handle
  function M.run_once(opts, on_line, on_exit)
    return require("sandbox.util.run_once").run(bin, opts, on_line, on_exit)
  end

  return M
end

return Shared
