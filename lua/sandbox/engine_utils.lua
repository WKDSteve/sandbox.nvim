---@module 'sandbox.engine_utils'
--- Which container engine to drive, and whether it can actually answer.

local notify = require("sandbox.notify")

local M = {}

--- The engines this plugin can drive, in preference order.
---
--- Declared once rather than written out at each site: the order *is* the
--- policy, and a second copy of it drifts.
---@type Sandbox.Engine[]
M.ENGINES = { "podman", "docker", "nerdctl" }

--- How long a liveness probe may take before the engine counts as silent.
---
--- Measured 2026-09-02 on Windows 11: a `version` call costs ~385 ms whether
--- the daemon answers or refuses, so this timeout is not about the normal
--- case. It is about a daemon that *hangs* rather than refuses, and a hang
--- must never take Neovim with it.
local PROBE_TIMEOUT_MS = 3000

--- Probe results for this session, keyed by engine name.
---@type table<string, boolean>
local responds = {}

--- Probes running in the background (`M.probe`), keyed by engine name: the
--- process and the callbacks waiting for its answer.
---@class Sandbox.Probe
---@field job? vim.SystemObj
---@field waiters fun(answer: boolean)[]

---@type table<string, Sandbox.Probe>
local pending = {}

--- Record the answer of the probe `p` of `name` and hand it to its waiters --
--- once, and only while `p` is still the pending probe of `name`. A probe that
--- `M.forget()` orphaned, or that a synchronous `responds` already settled,
--- arrives here a second time and is ignored.
---@param name string
---@param p Sandbox.Probe
---@param answer boolean
local function settle(name, p, answer)
  if pending[name] ~= p then
    return
  end
  pending[name] = nil
  responds[name] = answer
  for _, waiter in ipairs(p.waiters) do
    waiter(answer)
  end
end

--- Check if a command is available on the system.
--- Delegates to lib.nvim.core.has_exec, which memoizes the result per binary
--- name (this module's own version re-checked vim.fn.executable every call).
--- @param cmd string
--- @return boolean
function M.is_executable(cmd)
  return require("lib.nvim.core").has_exec(cmd)
end

--- Whether `name` can actually answer -- not whether its binary exists.
---
--- **The distinction this module was missing.** Being on `PATH` says an
--- engine is *installed*; it says nothing about a daemon being up. On a
--- machine with Podman Desktop installed but its Linux VM stopped, `podman`
--- is on `PATH`, wins the preference order, and every call fails after
--- ~370 ms -- while a perfectly good Docker engine sits beside it, never
--- asked. Found 2026-09-02 by hover.nvim's `scripts/onrequest_probe.lua`,
--- which reported a container preview that was registered, green in every
--- spec, and silent on the machine.
---
--- `version` is the question, plain and without `--format`: all three CLIs
--- accept it, and all three exit non-zero when the *server* half cannot be
--- reached (measured: podman 125, docker 1). A format template would answer
--- the same thing while adding a per-engine difference to get wrong.
---
--- **Memoized for the session**, because the probe is not cheap and no
--- cheaper phrasing exists -- the connect *is* the cost (`version`, `info`
--- and `image ls` measured at 380-640 ms alike). Starting a daemon after
--- Neovim is up is a normal thing to do, so `M.forget()` exists and
--- `:Sandbox engine reset` calls it.
---@param name string
---@return boolean
function M.responds(name)
  if responds[name] ~= nil then
    return responds[name]
  end
  if not M.is_executable(name) then
    responds[name] = false
    return false
  end

  -- A background probe of the same engine is already running (`M.probe`):
  -- wait for that process rather than starting a second one beside it.
  local p = pending[name]
  if p and p.job then
    local ok, result = pcall(function()
      return p.job:wait(PROBE_TIMEOUT_MS)
    end)
    settle(name, p, ok and type(result) == "table" and result.code == 0)
    if responds[name] ~= nil then
      return responds[name]
    end
  end

  local ok, result = pcall(function()
    return vim.system({ name, "version" }, { text = true }):wait(PROBE_TIMEOUT_MS)
  end)
  local answer = ok and type(result) == "table" and result.code == 0
  if p then
    -- A background probe whose spawn failed (no job, its `settle` still
    -- scheduled): this answer settles it, so the scheduled failure arrives
    -- for a probe that is no longer pending and cannot overwrite it.
    settle(name, p, answer)
  end
  responds[name] = answer
  return answer
end

--- `M.responds` without the wait: the same question, the same memo, the
--- answer delivered to `on_done(answer)`.
---
--- For the sites that only *show* the engine (`:Sandbox engine get`,
--- `reset`): their whole job is that one probe, so the synchronous form froze
--- the editor for the full connect (380-640 ms measured, up to
--- `PROBE_TIMEOUT_MS` on a hung daemon). A known answer is delivered at once,
--- synchronously; otherwise after the probe, on the main loop. Asking again
--- while a probe runs joins it instead of starting another process, and a
--- `M.forget()` in between makes the stale probe's answer go nowhere.
---@param name string
---@param on_done fun(answer: boolean)
---@return nil
function M.probe(name, on_done)
  if responds[name] ~= nil then
    on_done(responds[name])
    return
  end
  if not M.is_executable(name) then
    responds[name] = false
    on_done(false)
    return
  end

  local p = pending[name]
  if p then
    p.waiters[#p.waiters + 1] = on_done
    return
  end

  p = { waiters = { on_done } }
  pending[name] = p
  local spawn_ok, job = pcall(
    vim.system,
    { name, "version" },
    { text = true, timeout = PROBE_TIMEOUT_MS },
    function(obj)
      vim.schedule(function()
        settle(name, p, obj.code == 0)
      end)
    end
  )
  if not spawn_ok then
    -- `vim.system` throws synchronously when the spawn itself fails; the exit
    -- callback would never run, so the waiters would wait forever.
    vim.schedule(function()
      settle(name, p, false)
    end)
    return
  end
  p.job = job
end

--- Forget every probe result, so the next question is asked afresh.
---
--- For `:Sandbox engine reset` and for tests. Without it, starting your VM
--- mid-session would leave the plugin on the answer cached before you did.
--- A probe still running is orphaned: its answer is dropped, its waiters are
--- not called (`settle` checks the probe is still the pending one).
---@return nil
function M.forget()
  responds = {}
  pending = {}
end

--- Every engine whose CLI is on `PATH`, in preference order.
---@return Sandbox.Engine[]
function M.installed()
  local out = {}
  for _, name in ipairs(M.ENGINES) do
    if M.is_executable(name) then
      out[#out + 1] = name
    end
  end
  return out
end

--- The first installed engine, whether or not it answers.
---
--- Cheap on purpose -- `PATH` only, no process started. This is what
--- `config.setup` calls, and `setup` runs at startup: a liveness probe here
--- would cost every Neovim start ~385 ms per installed engine, to answer a
--- question nobody has asked yet.
--- @return Sandbox.Engine
function M.get_engine()
  local installed = M.installed()
  if installed[1] then
    return installed[1]
  end
  notify.error("No supported container engine (podman/docker/nerdctl) found in PATH.")
  return "docker" -- fallback to docker to avoid crash, user will see error
end

--- The first installed engine that actually answers.
---
--- Falls back to `get_engine()` when none of them does, so the error a user
--- eventually sees names a real engine: "docker is not running" is
--- actionable, "no engine" on a machine with three installed is not.
---
--- Costs one probe per installed engine, once per session, and is called
--- only from a site that is about to use the engine anyway.
--- @return Sandbox.Engine
function M.get_live_engine()
  for _, name in ipairs(M.installed()) do
    if M.responds(name) then
      return name
    end
  end
  return M.get_engine()
end

--- `M.get_live_engine` without the wait: the same pick, in the same
--- preference order (one probe at a time, stopping at the first engine that
--- answers -- no process is started for an engine the pick never reaches),
--- delivered to `on_done(name)`. Synchronous when every answer needed is
--- already known.
---@param on_done fun(name: Sandbox.Engine)
---@return nil
function M.get_live_engine_async(on_done)
  local installed = M.installed()
  local i = 0
  local function next_engine()
    i = i + 1
    local name = installed[i]
    if not name then
      on_done(M.get_engine())
      return
    end
    M.probe(name, function(answer)
      if answer then
        on_done(name)
      else
        next_engine()
      end
    end)
  end
  next_engine()
end

return M
