---@module 'sandbox.adapters.cli.registry_engine'
--- Engine Registry Adapter
---
--- Implements registry authentication (login/logout) operations of the
--- ContainerEngine port for Engine.
---
--- Shared by every engine that speaks the docker CLI: `new(name)` builds the aggregate from the modules
--- `sandbox.adapters.<name>.*`, so an engine that overrides one verb is picked up without a copy of this file.

local Shared = {}

--- @param name string the engine's directory (`docker`, `podman`, `nerdctl`)
--- @return table
function Shared.new(name)
  local engine = "sandbox.adapters." .. name

  local login = require(engine .. ".registry.login")
  local logout = require(engine .. ".registry.logout")

  --- Registry operations exposed by the Engine adapter
  return {
    login_registry = login.login,
    logout_registry = logout.logout,
  }
end

return Shared
