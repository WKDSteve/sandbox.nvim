---@module 'sandbox.adapters.cli.images.history_image'
--- CLI Adapter (docker, podman, nerdctl): Function to show an image's layer history
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

  --- Show an image's layer history
  --- @param image string: image ID or repository:tag
  --- @param on_done? fun(lines: string[]|nil, err: string|nil) Optional: when given, runs asynchronously (with
  ---        a progress indicator) and delivers exactly the values the synchronous form returns.
  --- @return string[]|nil lines, string|nil err
  function M.history_image(image, on_done)
    return run_argv.captured({ bin, "history", image }, function(ok, output)
      if not ok then
        return nil, output
      end
      return vim.split(output, "\n", { plain = true }), nil
    end, on_done, { stdout_only = true })
  end

  return M
end

return Shared
