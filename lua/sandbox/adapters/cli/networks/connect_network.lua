---@module 'sandbox.adapters.cli.networks.connect_network'
--- CLI Adapter (docker, podman, nerdctl): Functions to connect/disconnect a container to/from a network
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

  --- Connect a container to a network
  --- @param network string
  --- @param container_id string
  --- @param on_done? fun(ok: boolean, err: string|nil) Optional: when given, runs asynchronously (with a
  ---        progress indicator) and delivers exactly the values the synchronous form returns.
  --- @return boolean ok, string|nil err
  function M.connect_network(network, container_id, on_done)
    return run_argv.captured({ bin, "network", "connect", network, container_id }, run_argv.ok_or_err, on_done)
  end

  --- Disconnect a container from a network
  --- @param network string
  --- @param container_id string
  --- @param on_done? fun(ok: boolean, err: string|nil) Optional: when given, runs asynchronously (with a
  ---        progress indicator) and delivers exactly the values the synchronous form returns.
  --- @return boolean ok, string|nil err
  function M.disconnect_network(network, container_id, on_done)
    return run_argv.captured({ bin, "network", "disconnect", network, container_id }, run_argv.ok_or_err, on_done)
  end

  return M
end

return Shared
