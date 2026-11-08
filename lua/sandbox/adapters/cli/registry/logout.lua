---@module 'sandbox.adapters.cli.registry.logout'
--- CLI Adapter (docker, podman, nerdctl): Log out of a registry
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

  --- @param registry? string defaults to Docker Hub when omitted
  --- @return boolean ok
  --- @return string|nil err
  function M.logout(registry)
    local args = { bin, "logout" }
    if registry and registry ~= "" then
      args[#args + 1] = registry
    end

    local ok, output = run_argv.run_blocking_captured(args)
    if not ok then
      return false, output
    end

    return true, nil
  end

  return M
end

return Shared
