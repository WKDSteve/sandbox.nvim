---@module 'sandbox.adapters.cli.containers.pause_container'
--- CLI Adapter (docker, podman, nerdctl): Functions to pause/unpause a container
---
--- One definition for every engine that speaks the docker CLI: `new(bin)` returns the functions for
--- the binary `bin`. The per-engine module of the same name calls it (`sandbox.adapters.<engine>.containers.pause_container`).

local Shared = {}

--- @param bin string the engine's binary (`docker`, `podman`, `nerdctl`)
--- @return table the functions of this module
function Shared.new(bin)
  local M = {}

  --- Pause a specific container's processes
  --- @param container_id string: ID or name of the container to pause
  --- @param on_done? fun(ok: boolean, err: string|nil)
  function M.pause_container(container_id, on_done)
    local cmd = { bin, "pause", container_id }

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

  --- Resume a specific container's processes
  --- @param container_id string: ID or name of the container to unpause
  --- @param on_done? fun(ok: boolean, err: string|nil)
  function M.unpause_container(container_id, on_done)
    local cmd = { bin, "unpause", container_id }

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
