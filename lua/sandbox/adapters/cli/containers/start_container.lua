---@module 'sandbox.adapters.cli.containers.start_container'
--- CLI Adapter (docker, podman, nerdctl): Function to start a container
---
--- One definition for every engine that speaks the docker CLI: `new(bin)` returns the functions for
--- the binary `bin`. The per-engine module of the same name calls it
--- (`sandbox.adapters.<engine>.<group>.<verb>`).

local Shared = {}

--- @param bin string the engine's binary (`docker`, `podman`, `nerdctl`)
--- @return table the functions of this module
function Shared.new(bin)
  local run_argv = require("sandbox.util.run_argv")

  local M = {}

  --- Start a specific container
  --- @param container_id string: ID or name of the container to start
  --- @param on_done? fun(ok: boolean, err: string|nil) Optional: when given, runs asynchronously (with a
  ---        progress indicator) and delivers exactly the values the synchronous form returns. `start` waits until
  ---        the container runs, which can take seconds -- the user command always passes it.
  --- @return boolean ok, string|nil err
  function M.start_container(container_id, on_done)
    return run_argv.captured({ bin, "start", container_id }, run_argv.ok_or_err, on_done)
  end

  return M
end

return Shared
