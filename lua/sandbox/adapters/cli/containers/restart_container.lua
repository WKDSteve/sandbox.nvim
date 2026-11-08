---@module 'sandbox.adapters.cli.containers.restart_container'
--- CLI Adapter (docker, podman, nerdctl): Function to restart a container
---
--- One definition for every engine that speaks the docker CLI: `new(bin)` returns the functions for
--- the binary `bin`. The per-engine module of the same name calls it (`sandbox.adapters.<engine>.containers.restart_container`).

local Shared = {}

--- @param bin string the engine's binary (`docker`, `podman`, `nerdctl`)
--- @return table the functions of this module
function Shared.new(bin)
  local M = {}

  --- Restart a specific container
  --- @param container_id string: ID or name of the container to restart
  --- @param on_done? fun(ok: boolean, err: string|nil)
  function M.restart_container(container_id, on_done)
    local cmd = { bin, "restart", container_id }

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
