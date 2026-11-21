---@module 'sandbox.adapters.cli.images.list_images'
--- CLI Adapter (docker, podman, nerdctl): Function to list all images
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

  --- List all local images
  --- @param on_done? fun(...) Optional: when given, runs asynchronously (with a progress indicator) and
  ---        delivers exactly the values the synchronous form returns. The user command passes it; `<Tab>`
  ---        completion cannot (it needs the names as a return value) and stays synchronous.
  --- @return table[]|nil images, string|nil err
  function M.list_images(on_done)
    local function finish(ok, output)
      if not ok then
        return nil, output
      end

      local images = {}
      local decode_errors = {}
      for _, line in ipairs(vim.split(output, "\n", { trimempty = true })) do
        local decode_ok, image = pcall(vim.fn.json_decode, line)
        if decode_ok and image then
          table.insert(images, {
            id = image.ID or "<no id>",
            repository = image.Repository or "<no repository>",
            tag = image.Tag or "<no tag>",
            size = image.Size or "<no size>",
          })
        else
          table.insert(decode_errors, tostring(line))
        end
      end

      if #decode_errors > 0 then
        return images, "JSON decode error(s):\n" .. table.concat(decode_errors, "\n")
      end

      return images, nil
    end

    return run_argv.captured({ bin, "images", "--format", "{{json .}}" }, finish, on_done, { stdout_only = true })
  end

  return M
end

return Shared
