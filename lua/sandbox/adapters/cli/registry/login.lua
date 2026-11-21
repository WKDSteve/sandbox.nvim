---@module 'sandbox.adapters.cli.registry.login'
--- CLI Adapter (docker, podman, nerdctl): Authenticate against a registry
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

  --- Log in to a registry. The password is piped via stdin (--password-stdin)
  --- rather than passed as an argv element, so it never shows up in the
  --- process list or shell history.
  --- @param username string
  --- @param password string
  --- @param registry? string defaults to Docker Hub when omitted
  --- @param on_done? fun(ok: boolean, err: string|nil) Optional: when given, runs asynchronously (with a
  ---        progress indicator) and delivers exactly the values the synchronous form returns. The password
  ---        goes by stdin on both paths.
  --- @return boolean ok
  --- @return string|nil err
  function M.login(username, password, registry, on_done)
    local args = { bin, "login", "--username", username, "--password-stdin" }
    if registry and registry ~= "" then
      args[#args + 1] = registry
    end

    return run_argv.captured(args, run_argv.ok_or_err, on_done, { input = password })
  end

  return M
end

return Shared
