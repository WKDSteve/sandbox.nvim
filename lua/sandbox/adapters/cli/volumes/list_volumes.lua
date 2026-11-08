---@module 'sandbox.adapters.cli.volumes.list_volumes'
--- CLI Adapter (docker, podman, nerdctl): Function to list all volumes
---
--- One definition for every engine that speaks the docker CLI: `new(bin)` returns the functions for
--- the binary `bin`. The per-engine module of the same name calls it (`sandbox.adapters.<engine>.volumes.list_volumes`).

local Shared = {}

--- @param bin string the engine's binary (`docker`, `podman`, `nerdctl`)
--- @return table the functions of this module
function Shared.new(bin)
  local run_argv = require("sandbox.util.run_argv")

  local M = {}

  --- List all local volumes
  --- @return table[]|nil volumes, string|nil err
  function M.list_volumes()
    local ok, output = run_argv.run_blocking_captured({ bin, "volume", "ls", "--format", "{{json .}}" })

    if not ok then
      return nil, output
    end

    local volumes = {}
    local decode_errors = {}
    for _, line in ipairs(vim.split(output, "\n", { trimempty = true })) do
      local decode_ok, volume = pcall(vim.fn.json_decode, line)
      if decode_ok and type(volume) == "table" then
        table.insert(volumes, {
          name = volume.Name or "<no name>",
          driver = volume.Driver or "<no driver>",
          mountpoint = volume.Mountpoint or "",
        })
      else
        table.insert(decode_errors, tostring(line))
      end
    end

    if #decode_errors > 0 then
      return volumes, "JSON decode error(s):\n" .. table.concat(decode_errors, "\n")
    end

    return volumes, nil
  end

  return M
end

return Shared
