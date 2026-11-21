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
  --- @param on_done? fun(ok: boolean, err: string|nil) Optional: when given, runs asynchronously and delivers
  ---        exactly the values the synchronous form returns.
  --- @return boolean ok
  --- @return string|nil err
  function M.logout(registry, on_done)
    local args = { bin, "logout" }
    if registry and registry ~= "" then
      args[#args + 1] = registry
    end

    return run_argv.captured(args, run_argv.ok_or_err, on_done)
  end

  return M
end

return Shared
