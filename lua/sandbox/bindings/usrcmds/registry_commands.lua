---@module 'sandbox.bindings.usrcmds.registry_commands'
---@brief Registry authentication (`docker/podman login|logout`), needed
--- before push/pull against private registries. Prompts for username via
--- `kit.input` and password via `kit.input({secret = true})` (masked entry),
--- then pipes the password to the engine via stdin (--password-stdin)
--- rather than putting it in argv, where it would be visible in the
--- process list or shell history.
---@description
--- Without a registry argument each CLI uses its own default: Docker Hub for docker and nerdctl, for podman the
--- registries.conf default (docker.io unless configured otherwise); the messages name that, not a blanket Docker Hub.

local notify = require("sandbox.notify")
local friendly_error = require("sandbox.util.friendly_error")
local M = {}

--- The registry a login or logout went to, as the user is told it. Without a `registry` argument each engine uses its
--- own default: Docker Hub for docker and nerdctl; for podman the first of `unqualified-search-registries` in
--- registries.conf, docker.io unless that file names another.
---@param registry? string
---@return string
local function registry_label(registry)
  if registry and registry ~= "" then
    return registry
  end
  local ok, name = pcall(function()
    return require("sandbox").resolve_engine_name()
  end)
  if ok and name == "podman" then
    return "podman's default registry (docker.io unless registries.conf names another)"
  end
  return "Docker Hub"
end

--- Log in to a registry (prompts for username/password).
---@param registry? string the engine's default registry when omitted
function M.login(registry)
  local engine = require("sandbox").get_engine()
  if not engine then
    return
  end

  local kit = require("ui.kit")

  kit.input({
    title = "Registry username: ",
    on_submit = function(username)
      if not username or username == "" then
        notify.warn("Login cancelled: no username given")
        return
      end

      kit.input({
        title = "Registry password: ",
        secret = true,
        on_submit = function(password)
          if password == "" then
            notify.warn("Login cancelled: no password given")
            return
          end

          local usecase = require("sandbox.core.usecases.registry.login")
          local ok, err = usecase(engine, username, password, registry)
          if not ok then
            notify.error("Registry login failed: " .. friendly_error(err), { registry = registry, err = err })
            return
          end

          notify.info("Logged in to " .. registry_label(registry))
        end,
        on_cancel = function()
          notify.warn("Login cancelled: no password given")
        end,
      })
    end,
  })
end

--- Log out of a registry.
---@param registry? string the engine's default registry when omitted
function M.logout(registry)
  local engine = require("sandbox").get_engine()
  if not engine then
    return
  end

  local usecase = require("sandbox.core.usecases.registry.logout")
  local ok, err = usecase(engine, registry)
  if not ok then
    notify.error("Registry logout failed: " .. friendly_error(err), { registry = registry, err = err })
    return
  end

  notify.info("Logged out of " .. registry_label(registry))
end

return M
