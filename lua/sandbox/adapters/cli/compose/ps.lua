---@module 'sandbox.adapters.cli.compose.ps'
--- CLI Adapter (docker, podman, nerdctl): List services in a compose project
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

  --- @param file string path to the compose file
  --- @param on_done? fun(lines: string[]|nil, err: string|nil) Optional: when given, runs asynchronously (with
  ---        a progress indicator) and delivers exactly the values the synchronous form returns.
  --- @return string[]|nil lines, string|nil err
  function M.ps(file, on_done)
    return run_argv.captured({ bin, "compose", "-f", file, "ps" }, function(ok, output)
      if not ok then
        return nil, output
      end
      return vim.split(output, "\n", { plain = true }), nil
    end, on_done, { stdout_only = true })
  end

  return M
end

return Shared
