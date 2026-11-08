---@module 'sandbox.adapters.cli.images.pull_image'
--- CLI Adapter (docker, podman, nerdctl): Function to pull an image
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

  --- Pull an image from a remote registry without blocking the UI thread.
  --- @param name string: Name of the image to pull
  --- @param on_done fun(ok: boolean, err: string|nil)
  --- @return table handle with a `:stop()` method
  function M.pull_image(name, on_done)
    return run_argv.run_async_captured({ bin, "pull", name }, function(ok, output)
      -- Not `ok and nil or output`: in Lua that idiom collapses when the middle
      -- operand is nil, so it handed the pull/push log back as an error on every
      -- successful run.
      if ok then
        on_done(true, nil)
      else
        on_done(false, output)
      end
    end)
  end

  return M
end

return Shared
