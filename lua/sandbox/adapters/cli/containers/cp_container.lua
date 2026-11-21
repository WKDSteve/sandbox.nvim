---@module 'sandbox.adapters.cli.containers.cp_container'
--- CLI Adapter (docker, podman, nerdctl): Function to copy files/directories between host and container
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

  --- Copy a file or directory between the host and a container.
  --- Either src or dest must be in "container:path" form, matching `docker cp`.
  --- @param src string
  --- @param dest string
  --- @param on_done? fun(ok: boolean, err: string|nil) Optional: when given, runs asynchronously (with a
  ---        progress indicator: a large tree takes a while) and delivers exactly the values the synchronous form
  ---        returns.
  --- @return boolean ok, string|nil err
  function M.cp_container(src, dest, on_done)
    return run_argv.captured({ bin, "cp", src, dest }, run_argv.ok_or_err, on_done)
  end

  return M
end

return Shared
