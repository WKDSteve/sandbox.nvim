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
  --- @return string[]|nil lines, string|nil err
  function M.ps(file)
    local ok, output = run_argv.run_blocking_captured({ bin, "compose", "-f", file, "ps" })

    if not ok then
      return nil, output
    end

    return vim.split(output, "\n", { plain = true }), nil
  end

  return M
end

return Shared
