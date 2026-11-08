---@module 'sandbox.adapters.cli.containers_engine'
--- Engine Container Adapter
---
--- Implements container-related operations of the ContainerEngine port
--- for Engine: list, start, stop, exec, inspect, remove, prune, etc.
---
--- Shared by every engine that speaks the docker CLI: `new(name)` builds the aggregate from the modules
--- `sandbox.adapters.<name>.*`, so an engine that overrides one verb is picked up without a copy of this file.

local Shared = {}

--- @param name string the engine's directory (`docker`, `podman`, `nerdctl`)
--- @return table
function Shared.new(name)
  local engine = "sandbox.adapters." .. name

  local list_containers = require(engine .. ".containers.list_containers")
  local get_logs = require(engine .. ".containers.get_logs")
  local follow_logs = require(engine .. ".containers.follow_logs")
  local exec_in_container = require(engine .. ".containers.exec_in_container")
  local start = require(engine .. ".containers.start_container")
  local stop = require(engine .. ".containers.stop_container")
  local kill_container = require(engine .. ".containers.kill_container")
  local restart_container = require(engine .. ".containers.restart_container")
  local pause_container = require(engine .. ".containers.pause_container")
  local rename_container = require(engine .. ".containers.rename_container")
  local stats_container = require(engine .. ".containers.stats_container")
  local top_container = require(engine .. ".containers.top_container")
  local cp_container = require(engine .. ".containers.cp_container")
  local run_container = require(engine .. ".containers.run_container")
  local run_once = require(engine .. ".containers.run_once")
  local remove_container = require(engine .. ".containers.remove_container")
  local inspect_container = require(engine .. ".containers.inspect_container")
  local prune_containers = require(engine .. ".containers.prune_containers")

  --- Container operations exposed by the Engine adapter
  return {
    list_containers = list_containers.list_containers,
    get_logs = get_logs.get_logs,
    follow_logs = follow_logs.follow_logs,
    exec_in_container = exec_in_container.exec_in_container,
    start_container = start.start_container,
    stop_container = stop.stop_container,
    kill_container = kill_container.kill_container,
    restart_container = restart_container.restart_container,
    pause_container = pause_container.pause_container,
    unpause_container = pause_container.unpause_container,
    rename_container = rename_container.rename_container,
    stats_container = stats_container.stats_container,
    top_container = top_container.top_container,
    cp_container = cp_container.cp_container,
    run_container = run_container.run_container,
    run_once = run_once.run_once,
    remove_container = remove_container.remove_container,
    inspect_container = inspect_container.inspect_container,
    prune_containers = prune_containers.prune_containers,
  }
end

return Shared
