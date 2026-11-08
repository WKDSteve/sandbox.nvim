---@module 'sandbox.adapters.cli.images.tag_image'
--- CLI Adapter (docker, podman, nerdctl): Function to tag a local image
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

  --- Tag a local image with a new repository:tag
  --- @param source string: existing image ID or repository:tag
  --- @param target string: new repository:tag
  --- @return boolean ok, string|nil err
  function M.tag_image(source, target)
    local ok, output = run_argv.run_blocking_captured({ bin, "tag", source, target })

    if not ok then
      return false, output
    end

    return true, nil
  end

  return M
end

return Shared
