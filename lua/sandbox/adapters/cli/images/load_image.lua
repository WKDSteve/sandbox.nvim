---@module 'sandbox.adapters.cli.images.load_image'
--- CLI Adapter (docker, podman, nerdctl): Function to import an image from a tarball
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

  --- Load (import) an image from a tarball on disk
  --- @param path string: tarball path
  --- @return boolean ok, string|nil err
  function M.load_image(path)
    local ok, output = run_argv.run_blocking_captured({ bin, "load", "-i", path })

    if not ok then
      return false, output
    end

    return true, nil
  end

  return M
end

return Shared
