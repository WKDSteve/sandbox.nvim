---@module 'sandbox.adapters.cli.networks.prune_networks'
--- CLI Adapter (docker, podman, nerdctl): Function to prune unused networks
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

  --- Remove all unused local networks without blocking the UI thread.
  --- @param on_done? fun(ok: boolean, err: string|nil)
  --- @return table handle with a `:stop()` method
  function M.prune_networks(on_done)
    return run_argv.run_async_captured({ bin, "network", "prune", "-f" }, function(ok, output, code)
      if not on_done then
        return
      end
      if ok then
        -- Not `ok and nil or ...`: in Lua that idiom collapses when the middle
        -- operand is nil, so it would hand the captured output back as an error
        -- on every successful run.
        on_done(true, nil)
        return
      end
      output = vim.trim(output or "")
      on_done(false, output ~= "" and output or ("exit code " .. code))
    end)
  end

  return M
end

return Shared
