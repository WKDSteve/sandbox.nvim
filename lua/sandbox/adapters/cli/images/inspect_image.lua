---@module 'sandbox.adapters.cli.images.inspect_image'
--- CLI Adapter (docker, podman, nerdctl): Function to inspect an image
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

  --- Inspect a specific image and return its detailed metadata
  --- @param image string: image ID or repository:tag
  --- @return table|string[]: Image metadata as a table, or error message as string[]
  function M.inspect_image(image)
    local ok, output = run_argv.run_blocking_captured({ bin, "inspect", image })

    local decode_ok, result = pcall(vim.fn.json_decode, output)
    if not decode_ok or type(result) ~= "table" then
      return { "[sandbox.nvim] Invalid JSON output:\n" .. output }
    end

    if not ok or result[1] == nil then
      return { "[sandbox.nvim] Error inspecting image:\n" .. output }
    end

    return result[1]
  end

  return M
end

return Shared
