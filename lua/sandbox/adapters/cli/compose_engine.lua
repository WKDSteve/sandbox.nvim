---@module 'sandbox.adapters.cli.compose_engine'
--- Engine Compose Adapter Aggregator
---
--- Combines compose operations into a full implementation of the
--- ComposeEngine port, backed by the `docker compose` CLI plugin.
---
--- Shared by every engine that speaks the docker CLI: `new(name)` builds the aggregate from the modules
--- `sandbox.adapters.<name>.*`, so an engine that overrides one verb is picked up without a copy of this file.

local Shared = {}

--- @param name string the engine's directory (`docker`, `podman`, `nerdctl`)
--- @return table
function Shared.new(name)
  local engine = "sandbox.adapters." .. name

  local up = require(engine .. ".compose.up")
  local down = require(engine .. ".compose.down")
  local restart = require(engine .. ".compose.restart")
  local ps = require(engine .. ".compose.ps")
  local logs = require(engine .. ".compose.logs")

  return {
    up = up.up,
    down = down.down,
    restart = restart.restart,
    ps = ps.ps,
    logs = logs.logs,
  }
end

return Shared
