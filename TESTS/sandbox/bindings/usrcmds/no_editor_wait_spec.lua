-- The user commands that talk to a daemon must not make the editor wait for it.
--
-- Found by `testing perf` (2026-11-21, sandbox 1204 ms blocked over 46 starts): `:Sandbox container start`,
-- `rename`, `cp`, the image/volume/network lists, `registry logout`, `wsl list/start/stop` and the engine probe of
-- `:Sandbox engine get/reset` each started their CLI and then sat in `vim.system(...):wait()` -- 60-200 ms with
-- stand-ins, the full daemon connect (380-640 ms) or seconds (`docker start`, a `wsl -d` that boots the distro) on a
-- real machine, and forever on a hung daemon.
--
-- The second round (task `sandbox.nvim/restliche-blockierende-cli-aufrufe-und-erste`) covers the rest: image
-- tag/save/load/history/inspect, volume and network create/inspect, network connect/disconnect, compose ps/logs,
-- registry login, wsl set-default/set-version/export/import/shutdown-all, and the first engine detection of a session,
-- which made every command wait for `podman version` (up to the 3 s probe timeout) until the engine was known.
--
-- The fake `vim.system` below is what makes "does not wait" checkable: its `wait()` throws, so any path that still
-- waits fails, and it never exits by itself -- the test calls the exit callback by hand, which is the moment the
-- command's answer may appear and not one tick before. Nothing real is started.
---@diagnostic disable: need-check-nil, duplicate-set-field
local ui_reset = require("TESTS.sandbox.helpers.ui_reset")

---@class NoWait.Spawn
---@field cmd string[]
---@field opts table
---@field on_exit fun(obj: table)|nil

--- Every module of the plugin except its config (whose live options a case adjusts and restores).
---@param name any
---@return boolean
local function is_plugin_module(name)
  return type(name) == "string"
    and (name == "sandbox" or name:find("^sandbox%.") ~= nil)
    and name:find("^sandbox%.config") == nil
end

describe("user commands do not wait for the engine", function()
  local real_system
  ---@type NoWait.Spawn[]
  local spawned
  ---@type { level: string, msg: string }[]
  local notices
  local views
  local config
  local prev_style, prev_named, prev_confirm

  --- The process of `spawned[i]` writes `out` and exits with `code`.
  ---@param i integer
  ---@param code integer
  ---@param out? string
  local function exit(i, code, out)
    local s = spawned[i]
    assert.is_function(s.on_exit, table.concat(s.cmd, " ") .. " was started without an exit callback (waited for)")
    if out and type(s.opts.stdout) == "function" then
      s.opts.stdout(nil, out)
    end
    s.on_exit({ code = code, signal = 0, stdout = nil, stderr = nil })
  end

  ---@param level string
  ---@param text string
  ---@return boolean
  local function noted(level, text)
    for _, n in ipairs(notices) do
      if n.level == level and n.msg:find(text, 1, true) then
        return true
      end
    end
    return false
  end

  --- Wait for the `vim.schedule`d answer to land.
  ---@param check fun(): boolean
  local function settle(check)
    vim.wait(1000, check, 5)
  end

  before_each(function()
    spawned, notices, views = {}, {}, {}
    real_system = vim.system
    vim.system = function(cmd, opts, on_exit)
      spawned[#spawned + 1] = { cmd = cmd, opts = opts or {}, on_exit = on_exit }
      ---@diagnostic disable-next-line: return-type-mismatch
      return {
        pid = 4242,
        wait = function()
          error("the editor waited for `" .. table.concat(cmd, " ") .. "`", 0)
        end,
        kill = function() end,
      }
    end

    -- Fresh modules: every adapter must bind the real `run_argv` (other specs install a fake one), and every
    -- command module the notify fake below.
    for name in pairs(package.loaded) do
      if is_plugin_module(name) then
        package.loaded[name] = nil
      end
    end
    package.preload["sandbox.util.run_argv"] = nil
    package.loaded["sandbox.notify"] = {
      info = function(msg)
        notices[#notices + 1] = { level = "info", msg = msg }
      end,
      warn = function(msg)
        notices[#notices + 1] = { level = "warn", msg = msg }
      end,
      error = function(msg)
        notices[#notices + 1] = { level = "error", msg = msg }
      end,
    }
    for _, view in ipairs({
      "image_list_view_docker",
      "image_list_view_podman",
      "volume_list_view",
      "network_list_view",
      "log_view",
      "inspect_view",
    }) do
      package.loaded["sandbox.ui." .. view] = function(items, title)
        views[#views + 1] = { view = view, items = items, title = title }
      end
    end
    package.loaded["sandbox.util.compose_file"] = {
      find = function()
        return "/proj/compose.yml"
      end,
    }

    config = require("sandbox.config")
    prev_style, prev_named = config.options.progress_style, config.engine_named
    prev_confirm = config.options.confirm_destructive
    -- Headless and observable: no window, no toast, no confirmation dialog.
    config.options.progress_style = "statusline"
    config.options.confirm_destructive = false
    config.engine_named = false
    vim.g.sandbox_engine = "docker"
  end)

  after_each(function()
    vim.system = real_system
    vim.g.sandbox_engine = nil
    config.options.progress_style = prev_style
    config.options.confirm_destructive = prev_confirm
    config.engine_named = prev_named
    for name in pairs(package.loaded) do
      if is_plugin_module(name) then
        package.loaded[name] = nil
      end
    end
    ui_reset.restore()
  end)

  --- command, the argv it must start, what the success says, how to run it
  local CASES = {
    {
      name = "container start",
      argv = "docker start sbx-db",
      says = "Container started successfully: sbx-db",
      run = function()
        require("sandbox.bindings.usrcmds.container_commands").start("sbx-db")
      end,
    },
    {
      name = "container rename",
      argv = "docker rename sbx-web sbx-new",
      says = "Container renamed: sbx-web -> sbx-new",
      run = function()
        require("sandbox.bindings.usrcmds.container_commands").rename("sbx-web", "sbx-new")
      end,
    },
    {
      name = "container cp",
      argv = "docker cp sbx-web:/etc/hostname ./h.txt",
      says = "Copied: sbx-web:/etc/hostname -> ./h.txt",
      run = function()
        require("sandbox.bindings.usrcmds.container_commands").cp("sbx-web:/etc/hostname", "./h.txt")
      end,
    },
    {
      name = "registry logout",
      argv = "docker logout ghcr.io",
      says = "Logged out of ghcr.io",
      run = function()
        require("sandbox.bindings.usrcmds.registry_commands").logout("ghcr.io")
      end,
    },
    {
      name = "wsl start",
      argv = "wsl -d sbx-wsl -- echo",
      says = "WSL distro started: sbx-wsl",
      run = function()
        require("sandbox.bindings.usrcmds.wsl_commands").start("sbx-wsl")
      end,
    },
    {
      name = "wsl stop",
      argv = "wsl --terminate sbx-wsl",
      says = "WSL distro terminated: sbx-wsl",
      run = function()
        require("sandbox.bindings.usrcmds.wsl_commands").stop("sbx-wsl")
      end,
    },
    {
      name = "image tag",
      argv = "docker tag alpine:edge sbx:t",
      says = "Tagged: alpine:edge -> sbx:t",
      run = function()
        require("sandbox.bindings.usrcmds.image_commands").tag("alpine:edge", "sbx:t")
      end,
    },
    {
      name = "image save",
      argv = "docker save -o sbx.tar alpine:edge",
      says = "Image saved: alpine:edge -> sbx.tar",
      run = function()
        require("sandbox.bindings.usrcmds.image_commands").save("alpine:edge", "sbx.tar")
      end,
    },
    {
      name = "image load",
      argv = "docker load -i sbx.tar",
      says = "Image loaded from: sbx.tar",
      run = function()
        require("sandbox.bindings.usrcmds.image_commands").load("sbx.tar")
      end,
    },
    {
      name = "volume create",
      argv = "docker volume create sbx-vol",
      says = "Volume created: sbx-vol",
      run = function()
        require("sandbox.bindings.usrcmds.volume_commands").create("sbx-vol")
      end,
    },
    {
      name = "network create",
      argv = "docker network create sbx-net",
      says = "Network created: sbx-net",
      run = function()
        require("sandbox.bindings.usrcmds.network_commands").create("sbx-net")
      end,
    },
    {
      name = "network connect",
      argv = "docker network connect sbx-net sbx-c",
      says = "sbx-c",
      run = function()
        require("sandbox.bindings.usrcmds.network_commands").connect("sbx-net", "sbx-c")
      end,
    },
    {
      name = "network disconnect",
      argv = "docker network disconnect sbx-net sbx-c",
      says = "Disconnected sbx-c from network sbx-net",
      run = function()
        require("sandbox.bindings.usrcmds.network_commands").disconnect("sbx-net", "sbx-c")
      end,
    },
    {
      name = "wsl set-default",
      argv = "wsl --set-default sbx-wsl",
      says = "Default WSL distro set to: sbx-wsl",
      run = function()
        require("sandbox.bindings.usrcmds.wsl_commands").set_default("sbx-wsl")
      end,
    },
    {
      name = "wsl set-version",
      argv = "wsl --set-version sbx-wsl 2",
      says = "WSL distro sbx-wsl set to version 2",
      run = function()
        require("sandbox.bindings.usrcmds.wsl_commands").set_version("sbx-wsl", "2")
      end,
    },
    {
      name = "wsl export",
      argv = "wsl --export sbx-wsl sbx.tar",
      says = "WSL distro sbx-wsl exported to sbx.tar",
      run = function()
        require("sandbox.bindings.usrcmds.wsl_commands").export("sbx-wsl", "sbx.tar")
      end,
    },
    {
      name = "wsl import",
      argv = "wsl --import sbx-new sbx-dir sbx.tar",
      says = "WSL distro imported: sbx-new",
      run = function()
        require("sandbox.bindings.usrcmds.wsl_commands").import("sbx-new", "sbx-dir", "sbx.tar")
      end,
    },
    {
      name = "wsl shutdown-all",
      argv = "wsl --shutdown",
      says = "WSL shut down",
      run = function()
        require("sandbox.bindings.usrcmds.wsl_commands").shutdown_all()
      end,
    },
  }

  for _, case in ipairs(CASES) do
    it(case.name .. " returns before the CLI exits and reports when it does", function()
      case.run()

      assert.are.equal(1, #spawned)
      assert.are.equal(case.argv, table.concat(spawned[1].cmd, " "))
      assert.are.same({}, notices, "answered before the process exited")

      exit(1, 0)
      settle(function()
        return #notices > 0
      end)
      assert.is_true(noted("info", case.says), vim.inspect(notices))
    end)
  end

  it("container start reports the CLI's error when it fails", function()
    require("sandbox.bindings.usrcmds.container_commands").start("sbx-db")
    exit(1, 1, "Error response from daemon: No such container: sbx-db\n")
    settle(function()
      return #notices > 0
    end)
    assert.is_true(noted("error", "No such container: sbx-db"), vim.inspect(notices))
  end)

  --- command, the argv it must start, the view it opens and the title it gives it
  local VIEWS = {
    {
      name = "image history",
      argv = "docker history alpine:edge",
      view = "log_view",
      title = "image-history/alpine:edge",
      run = function()
        require("sandbox.bindings.usrcmds.image_commands").history("alpine:edge")
      end,
    },
    {
      name = "image inspect",
      argv = "docker inspect alpine:edge",
      view = "inspect_view",
      title = "image-alpine:edge",
      run = function()
        require("sandbox.bindings.usrcmds.image_commands").inspect("alpine:edge")
      end,
    },
    {
      name = "volume inspect",
      argv = "docker volume inspect sbx-vol",
      view = "inspect_view",
      title = "volume-sbx-vol",
      run = function()
        require("sandbox.bindings.usrcmds.volume_commands").inspect("sbx-vol")
      end,
    },
    {
      name = "network inspect",
      argv = "docker network inspect sbx-net",
      view = "inspect_view",
      title = "network-sbx-net",
      run = function()
        require("sandbox.bindings.usrcmds.network_commands").inspect("sbx-net")
      end,
    },
    {
      name = "compose ps",
      argv = "docker compose -f /proj/compose.yml ps",
      view = "log_view",
      title = "compose-ps",
      run = function()
        require("sandbox.bindings.usrcmds.compose_commands").ps()
      end,
    },
    {
      name = "compose logs",
      argv = "docker compose -f /proj/compose.yml logs",
      view = "log_view",
      title = "compose-logs",
      run = function()
        require("sandbox.bindings.usrcmds.compose_commands").logs()
      end,
    },
  }

  for _, case in ipairs(VIEWS) do
    it(case.name .. " opens its view once the CLI answers, not before", function()
      case.run()

      assert.are.equal(1, #spawned)
      assert.are.equal(case.argv, table.concat(spawned[1].cmd, " "))
      assert.are.same({}, views)

      exit(1, 0, '[{"Name":"sbx"}]\n')
      settle(function()
        return #views > 0
      end)
      assert.are.equal(case.view, views[1].view)
      assert.are.equal(case.title, views[1].title)
      assert.are.same({}, notices)
    end)
  end

  it("compose logs reports the CLI's error when it fails", function()
    require("sandbox.bindings.usrcmds.compose_commands").logs()
    exit(1, 1, "no such service\n")
    settle(function()
      return #notices > 0
    end)
    assert.is_true(noted("error", "Failed to get compose logs"), vim.inspect(notices))
    assert.are.same({}, views)
  end)

  it("registry login hands the password over stdin, never argv, and reports after the CLI exits", function()
    local answers = { "sbx-user", "s3cret" }
    package.loaded["ui.kit"] = {
      input = function(opts)
        opts.on_submit(table.remove(answers, 1))
      end,
    }
    require("sandbox.bindings.usrcmds.registry_commands").login("ghcr.io")
    package.loaded["ui.kit"] = nil

    assert.are.equal(1, #spawned)
    assert.are.equal("docker login --username sbx-user --password-stdin ghcr.io", table.concat(spawned[1].cmd, " "))
    assert.are.equal("s3cret", spawned[1].opts.stdin)
    assert.are.same({}, notices)

    exit(1, 0)
    settle(function()
      return #notices > 0
    end)
    assert.is_true(noted("info", "Logged in to ghcr.io"), vim.inspect(notices))
  end)

  local LISTS = {
    {
      group = "image",
      argv = "docker images --format {{json .}}",
      view = "image_list_view_docker",
      field = "repository",
    },
    { group = "volume", argv = "docker volume ls --format {{json .}}", view = "volume_list_view", field = "name" },
    { group = "network", argv = "docker network ls --format {{json .}}", view = "network_list_view", field = "name" },
  }

  for _, list in ipairs(LISTS) do
    it(list.group .. " list opens its view once the CLI answers, not before", function()
      require("sandbox.bindings.usrcmds." .. list.group .. "_commands").list()

      assert.are.equal(1, #spawned)
      assert.are.equal(list.argv, table.concat(spawned[1].cmd, " "))
      assert.are.same({}, views)

      -- A daemon warning on stderr must not turn into a parse error: a list parses stdout only.
      if type(spawned[1].opts.stderr) == "function" then
        spawned[1].opts.stderr(nil, "WARNING: context is deprecated\n")
      end
      exit(1, 0, '{"ID":"x1","Repository":"alpine","Name":"alpine"}\n')
      settle(function()
        return #views > 0
      end)
      assert.are.equal(list.view, views[1].view)
      assert.are.equal("alpine", views[1].items[1][list.field])
      assert.are.same({}, notices)
    end)
  end

  it("image list shows the view of the engine that ran it, even if the engine changes meanwhile", function()
    require("sandbox.bindings.usrcmds.image_commands").list()
    -- `:Sandbox engine set podman` while docker's answer is still on its way.
    vim.g.sandbox_engine = "podman"

    exit(1, 0, '{"ID":"x1","Repository":"alpine","Tag":"edge"}\n')
    settle(function()
      return #views > 0
    end)
    assert.are.equal("image_list_view_docker", views[1].view)
  end)

  it("wsl list opens its buffer once wsl.exe answers, not before", function()
    require("sandbox.bindings.usrcmds.wsl_commands").list()
    local before = vim.api.nvim_get_current_buf()

    assert.are.equal("wsl --list --verbose", table.concat(spawned[1].cmd, " "))
    assert.are.equal(before, vim.api.nvim_get_current_buf())

    exit(1, 0, "  NAME      STATE           VERSION\n* sbx-wsl   Stopped         2\n")
    settle(function()
      return vim.api.nvim_get_current_buf() ~= before
    end)
    local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
    assert.is_truthy(text:find("sbx-wsl", 1, true), text)
  end)

  describe("engine detection", function()
    local utils

    before_each(function()
      vim.g.sandbox_engine = nil
      package.loaded["sandbox.util.project_config"] = {
        read_engine_override = function()
          return nil, false
        end,
      }
      utils = require("sandbox.engine_utils")
      utils.is_executable = function(cmd)
        return cmd == "podman" or cmd == "docker"
      end
    end)

    it("the first engine command of a session probes in the background, then runs", function()
      require("sandbox.bindings.usrcmds").setup()
      vim.cmd("Sandbox image tag alpine:edge sbx:t")

      assert.are.equal(1, #spawned, "only the probe runs before the engine is known")
      assert.are.equal("podman version", table.concat(spawned[1].cmd, " "))

      -- A second command typed while the probe runs joins it.
      vim.cmd("Sandbox volume create sbx-vol")
      assert.are.equal(1, #spawned)

      exit(1, 0)
      settle(function()
        return #spawned == 3
      end)
      assert.are.equal("podman tag alpine:edge sbx:t", table.concat(spawned[2].cmd, " "))
      assert.are.equal("podman volume create sbx-vol", table.concat(spawned[3].cmd, " "))

      -- Known now: the next command starts its CLI right away, without a probe.
      vim.cmd("Sandbox network create sbx-net")
      assert.are.equal("podman network create sbx-net", table.concat(spawned[4].cmd, " "))
      pcall(vim.api.nvim_del_user_command, "Sandbox")
      pcall(vim.api.nvim_del_user_command, "Sbx")
    end)

    it("the statusline does not wait for detection either", function()
      local statusline = require("sandbox.statusline")
      assert.are.equal("", statusline.status())
      assert.are.equal("podman version", table.concat(spawned[1].cmd, " "))
      -- every redraw while the probe runs joins it
      statusline.status()
      assert.are.equal(1, #spawned)

      exit(1, 0)
      settle(function()
        return require("sandbox.engine_utils").peek_live_engine() == "podman"
      end)
      statusline.status()
      assert.are.equal("podman ps", table.concat(spawned[2].cmd, " "):sub(1, #"podman ps"))
    end)

    it("engine get probes in the background and reports after the answer", function()
      require("sandbox.bindings.usrcmds.engine_commands").get()

      assert.are.equal(1, #spawned)
      assert.are.equal("podman version", table.concat(spawned[1].cmd, " "))
      assert.are.same({}, notices)

      exit(1, 0)
      settle(function()
        return #notices > 0
      end)
      assert.is_true(noted("info", "Active engine: podman (detected)"), vim.inspect(notices))
    end)

    it("falls through to the next engine when the preferred one does not answer", function()
      require("sandbox.bindings.usrcmds.engine_commands").get()
      exit(1, 125)
      settle(function()
        return #spawned > 1
      end)
      assert.are.equal("docker version", table.concat(spawned[2].cmd, " "))
      exit(2, 0)
      settle(function()
        return #notices > 0
      end)
      assert.is_true(noted("info", "Active engine: docker (detected)"), vim.inspect(notices))
    end)

    it("engine reset forgets, probes in the background, and reports after the answer", function()
      utils.probe("podman", function() end)
      exit(1, 0)
      settle(function()
        return utils.responds("podman") ~= nil
      end)

      require("sandbox.bindings.usrcmds.engine_commands").reset()
      assert.are.equal(2, #spawned, "reset must ask afresh")
      assert.are.same({}, notices)

      exit(2, 0)
      settle(function()
        return #notices > 0
      end)
      assert.is_true(noted("info", "Session engine override cleared; using podman"), vim.inspect(notices))
    end)

    it("a second question while a probe runs joins it instead of starting another process", function()
      local answers = {}
      utils.probe("podman", function(a)
        answers[#answers + 1] = a
      end)
      utils.probe("podman", function(a)
        answers[#answers + 1] = a
      end)
      assert.are.equal(1, #spawned)

      exit(1, 0)
      settle(function()
        return #answers == 2
      end)
      assert.are.same({ true, true }, answers)
      -- Remembered: asking again starts nothing and answers at once.
      assert.is_true(utils.responds("podman"))
      assert.are.equal(1, #spawned)
    end)

    it("a probe orphaned by forget() answers nobody and leaves no memo", function()
      local answers = {}
      utils.probe("podman", function(a)
        answers[#answers + 1] = a
      end)
      utils.forget()

      exit(1, 0)
      vim.wait(50)
      assert.are.same({}, answers)

      utils.probe("podman", function(a)
        answers[#answers + 1] = a
      end)
      assert.are.equal(2, #spawned, "the forgotten answer must not be reused")
    end)

    it("a failed background spawn does not overwrite the answer a synchronous question found", function()
      vim.system = function()
        error("ENOENT: spawn failed", 0)
      end
      local answers = {}
      utils.probe("podman", function(a)
        answers[#answers + 1] = a
      end)
      -- Before the scheduled failure lands, the editor asks synchronously -- and this time the spawn works.
      vim.system = function()
        ---@diagnostic disable-next-line: return-type-mismatch
        return {
          wait = function()
            return { code = 0 }
          end,
        }
      end
      assert.is_true(utils.responds("podman"))

      vim.wait(50)
      assert.is_true(utils.responds("podman"))
      assert.are.same({ true }, answers)
    end)

    it("the synchronous question waits on a running probe rather than starting a second one", function()
      local job_waits = 0
      vim.system = function(cmd, opts, on_exit)
        spawned[#spawned + 1] = { cmd = cmd, opts = opts or {}, on_exit = on_exit }
        ---@diagnostic disable-next-line: return-type-mismatch
        return {
          -- The probe's process has exited; `wait` hands back its result, as `vim.SystemObj:wait` does.
          wait = function()
            job_waits = job_waits + 1
            return { code = 0 }
          end,
        }
      end
      utils.probe("podman", function() end)
      vim.system = function()
        error("a second process was started", 0)
      end

      assert.is_true(utils.responds("podman"))
      assert.are.equal(1, job_waits)
      assert.are.equal(1, #spawned)
    end)
  end)
end)
