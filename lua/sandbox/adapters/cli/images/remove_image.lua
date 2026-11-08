---@module 'sandbox.adapters.cli.images.remove_image'
--- CLI Adapter (docker, podman, nerdctl): Function to remove a local image
---
--- One definition for every engine that speaks the docker CLI: `new(bin)` returns the functions for
--- the binary `bin`. The per-engine module of the same name calls it
--- (`sandbox.adapters.<engine>.<group>.<verb>`).

local Shared = {}

--- @param bin string the engine's binary (`docker`, `podman`, `nerdctl`)
--- @return table the functions of this module
function Shared.new(bin)
  local M = {}

  --- Remove a specific image by ID or repository:tag
  --- @param id string: Image ID or name
  --- @param on_done? fun(ok: boolean, err: string|nil)
  function M.remove_image(id, on_done)
    local stderr_lines = {}

    vim.fn.jobstart({ bin, "rmi", id }, {
      stdout_buffered = true,
      stderr_buffered = true,
      on_stderr = function(_, data)
        if data then
          vim.list_extend(stderr_lines, data)
        end
      end,
      on_exit = function(_, code)
        vim.schedule(function()
          if on_done then
            if code == 0 then
              on_done(true, nil)
            else
              local err = table.concat(stderr_lines, "\n")
              on_done(false, err ~= "" and err or ("exit code " .. code))
            end
          end
        end)
      end,
    })
  end

  return M
end

return Shared
