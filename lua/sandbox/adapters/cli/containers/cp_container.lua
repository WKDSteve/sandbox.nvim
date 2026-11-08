---@module 'sandbox.adapters.cli.containers.cp_container'
--- CLI Adapter (docker, podman, nerdctl): Function to copy files/directories between host and container
---
--- One definition for every engine that speaks the docker CLI: `new(bin)` returns the functions for
--- the binary `bin`. The per-engine module of the same name calls it (`sandbox.adapters.<engine>.containers.cp_container`).

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
  --- @return boolean ok, string|nil err
  function M.cp_container(src, dest)
    local ok, output = run_argv.run_blocking_captured({ bin, "cp", src, dest })

    if not ok then
      return false, output
    end

    return true, nil
  end

  return M
end

return Shared
