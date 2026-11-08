---@module 'sandbox.adapters.cli.volumes.inspect_volume'
--- CLI Adapter (docker, podman, nerdctl): Function to inspect a volume
---
--- One definition for every engine that speaks the docker CLI: `new(bin)` returns the functions for
--- the binary `bin`. The per-engine module of the same name calls it (`sandbox.adapters.<engine>.volumes.inspect_volume`).

local Shared = {}

--- @param bin string the engine's binary (`docker`, `podman`, `nerdctl`)
--- @return table the functions of this module
function Shared.new(bin)
  local run_argv = require("sandbox.util.run_argv")

  local M = {}

  --- Inspect a specific volume and return its detailed metadata
  --- @param name string
  --- @return table|string[]: Volume metadata as a table, or error message as string[]
  function M.inspect_volume(name)
    local ok, output = run_argv.run_blocking_captured({ bin, "volume", "inspect", name })

    local decode_ok, result = pcall(vim.fn.json_decode, output)
    if not decode_ok or type(result) ~= "table" then
      return { "[sandbox.nvim] Invalid JSON output:\n" .. output }
    end

    if not ok or result[1] == nil then
      return { "[sandbox.nvim] Error inspecting volume:\n" .. output }
    end

    return result[1]
  end

  return M
end

return Shared
