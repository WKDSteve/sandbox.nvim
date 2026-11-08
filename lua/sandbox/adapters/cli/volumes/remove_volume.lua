---@module 'sandbox.adapters.cli.volumes.remove_volume'
--- CLI Adapter (docker, podman, nerdctl): Function to remove a volume
---
--- One definition for every engine that speaks the docker CLI: `new(bin)` returns the functions for
--- the binary `bin`. The per-engine module of the same name calls it
--- (`sandbox.adapters.<engine>.<group>.<verb>`).

local Shared = {}

--- @param bin string the engine's binary (`docker`, `podman`, `nerdctl`)
--- @return table the functions of this module
function Shared.new(bin)
  local M = {}

  --- Remove a specific volume by name
  --- @param name string
  --- @param on_done? fun(ok: boolean, err: string|nil)
  function M.remove_volume(name, on_done)
    local cmd = { bin, "volume", "rm", name }

    vim.fn.jobstart(cmd, {
      on_exit = function(_, code, _)
        vim.schedule(function()
          if on_done then
            if code == 0 then
              on_done(true, nil)
            else
              on_done(false, "exit code " .. code)
            end
          end
        end)
      end,
    })
  end

  return M
end

return Shared
