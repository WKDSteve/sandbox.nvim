---@module 'sandbox.adapters.cli.networks.list_networks'
--- CLI Adapter (docker, podman, nerdctl): Function to list all networks
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

  --- List all local networks
  --- @param on_done? fun(...) Optional: when given, runs asynchronously (with a progress indicator) and
  ---        delivers exactly the values the synchronous form returns. The user command passes it; `<Tab>`
  ---        completion cannot (it needs the names as a return value) and stays synchronous.
  --- @return table[]|nil networks, string|nil err
  function M.list_networks(on_done)
    local function finish(ok, output)
      if not ok then
        return nil, output
      end

      local networks = {}
      local decode_errors = {}
      for _, line in ipairs(vim.split(output, "\n", { trimempty = true })) do
        local decode_ok, network = pcall(vim.fn.json_decode, line)
        if decode_ok and type(network) == "table" then
          table.insert(networks, {
            id = network.ID or "<no id>",
            name = network.Name or "<no name>",
            driver = network.Driver or "<no driver>",
            scope = network.Scope or "",
          })
        else
          table.insert(decode_errors, tostring(line))
        end
      end

      if #decode_errors > 0 then
        return networks, "JSON decode error(s):\n" .. table.concat(decode_errors, "\n")
      end

      return networks, nil
    end

    return run_argv.captured(
      { bin, "network", "ls", "--format", "{{json .}}" },
      finish,
      on_done,
      { stdout_only = true }
    )
  end

  return M
end

return Shared
