-- containers.run_once for docker, podman and nerdctl: the argv it would spawn, the streamed output,
-- the exit result, and the guarantee that a timeout or cancel stops the CONTAINER (kill, then
-- rm -f), not only the CLI. The process spawner (`sandbox.util.run_once.system`) is faked, so no
-- engine needs to be installed.
---@diagnostic disable: need-check-nil

local run_once = require("sandbox.util.run_once")
local ENGINES = { "docker", "podman", "nerdctl" }

--- A fake spawner: the main `run` command stays pending until the test finishes it; kill and rm
--- answer at once.
---@return table fake
local function install()
  local fake = { calls = {}, killed = false }
  local real = run_once.system
  run_once.system = function(cmd, opts, on_exit)
    fake.calls[#fake.calls + 1] = cmd
    if cmd[2] == "run" then
      fake.opts, fake.on_exit = opts, on_exit
      fake.obj = {
        kill = function()
          fake.killed = true
          if fake.on_exit then
            fake.on_exit({ code = 143 })
          end
        end,
      }
      return fake.obj
    end
    if on_exit then
      on_exit({ code = 0 })
    end
    return { kill = function() end }
  end
  function fake.restore()
    run_once.system = real
  end
  function fake.feed(stream, data)
    fake.opts[stream](nil, data)
  end
  function fake.finish(res)
    fake.on_exit(res)
  end
  return fake
end

local function joined(argv)
  return table.concat(argv, " ")
end

describe("run_once argv", function()
  for _, engine in ipairs(ENGINES) do
    it(engine .. ": --rm, attached, no network, named, image then command", function()
      local argv, err, name = run_once.argv(engine, { image = "alpine", command = { "echo", "a b" } })
      assert.is_nil(err)
      assert.equals(engine, argv[1])
      assert.equals("run", argv[2])
      assert.equals("--rm", argv[3])
      assert.is_nil(joined(argv):find(" -d ", 1, true), "attached, never detached")
      assert.is_truthy(joined(argv):find("--name " .. name, 1, true))
      assert.is_truthy(joined(argv):find("--network none", 1, true))
      assert.same({ "alpine", "echo", "a b" }, { unpack(argv, #argv - 2) })
    end)
  end

  it("mounts: read-only and read-write, a Windows path stays one element", function()
    local argv = run_once.argv("podman", {
      image = "x",
      mounts = {
        { src = "C:\\Users\\a b\\src", dst = "/work", ro = true },
        { src = "/data", dst = "/out" },
      },
    })
    local specs = {}
    for i, a in ipairs(argv) do
      if a == "--mount" then
        specs[#specs + 1] = argv[i + 1]
      end
    end
    assert.same({
      "type=bind,source=C:\\Users\\a b\\src,target=/work,readonly",
      "type=bind,source=/data,target=/out",
    }, specs)
  end)

  it("workdir, env (sorted), network and name are passed", function()
    local argv = run_once.argv("docker", {
      image = "x",
      workdir = "/w",
      name = "mine",
      network = "bridge",
      env = { B = "2", A = "1" },
    })
    local text = joined(argv)
    assert.is_truthy(text:find("--name mine", 1, true))
    assert.is_truthy(text:find("--network bridge", 1, true))
    assert.is_truthy(text:find("-w /w", 1, true))
    assert.is_truthy(text:find("-e A=1 -e B=2", 1, true))
  end)

  it("refuses a missing image and a mount that could break the option", function()
    assert.is_nil((run_once.argv("docker", {})))
    local argv, err = run_once.argv("docker", { image = "x", mounts = { { src = "a,b", dst = "/c" } } })
    assert.is_nil(argv)
    assert.matches("mount", err)
  end)

  it("generates a different name per call", function()
    local _, _, n1 = run_once.argv("docker", { image = "x" })
    local _, _, n2 = run_once.argv("docker", { image = "x" })
    assert.not_equals(n1, n2)
  end)
end)

describe("run_once lifecycle", function()
  local fake
  before_each(function()
    fake = install()
  end)
  after_each(function()
    fake.restore()
  end)

  for _, engine in ipairs(ENGINES) do
    it(engine .. ": streams whole lines per stream and reports the exit code", function()
      local lines, result = {}, nil
      local adapter = require("sandbox.adapters." .. engine .. ".containers.run_once")
      adapter.run_once({ image = "alpine" }, function(stream, line)
        lines[#lines + 1] = stream .. ":" .. line
      end, function(res)
        result = res
      end)
      assert.equals(engine, fake.calls[1][1])
      fake.feed("stdout", "hel")
      fake.feed("stdout", "lo\nwor")
      fake.feed("stderr", "oops\r\n")
      fake.feed("stdout", "ld")
      fake.finish({ code = 3 })
      vim.wait(500, function()
        return result ~= nil
      end)
      assert.same({ "stdout:hello", "stderr:oops", "stdout:world" }, lines)
      assert.equals(3, result.code)
      assert.is_false(result.timed_out)
      assert.is_false(result.cancelled)
    end)
  end

  it("on_exit fires once, after the last line", function()
    local order = {}
    run_once.run("docker", { image = "x" }, function(_, l)
      order[#order + 1] = l
    end, function()
      order[#order + 1] = "exit"
    end)
    fake.feed("stdout", "a\nb")
    fake.finish({ code = 0 })
    fake.finish({ code = 0 })
    vim.wait(300, function()
      return #order >= 3
    end)
    vim.wait(50)
    assert.same({ "a", "b", "exit" }, order)
  end)

  it("a timeout kills the container, then removes it, and says so", function()
    local result
    run_once.run("podman", { image = "x", timeout_ms = 30, name = "c1" }, nil, function(res)
      result = res
    end)
    vim.wait(2000, function()
      return result ~= nil
    end)
    assert.is_true(result.timed_out)
    assert.is_false(result.cancelled)
    local kill_at, rm_at
    for i, c in ipairs(fake.calls) do
      if joined(c) == "podman kill c1" then
        kill_at = i
      elseif joined(c) == "podman rm -f c1" then
        rm_at = rm_at or i
      end
    end
    assert.is_truthy(kill_at, "the container itself is killed")
    assert.is_truthy(rm_at, "and removed")
    assert.is_true(kill_at < rm_at)
    assert.is_true(fake.killed, "the CLI process too")
  end)

  it("cancel() stops the container and reports cancelled", function()
    local result
    local handle = run_once.run("docker", { image = "x", name = "c2" }, nil, function(res)
      result = res
    end)
    handle.cancel()
    handle.cancel()
    vim.wait(1000, function()
      return result ~= nil
    end)
    assert.is_true(result.cancelled)
    assert.is_false(result.timed_out)
    local killed = 0
    for _, c in ipairs(fake.calls) do
      if joined(c) == "docker kill c2" then
        killed = killed + 1
      end
    end
    assert.equals(1, killed, "a second cancel does nothing")
  end)

  it("a finished run is not touched by a late timeout or cancel", function()
    local result
    local handle = run_once.run("docker", { image = "x", timeout_ms = 40 }, nil, function(res)
      result = res
    end)
    fake.finish({ code = 0 })
    handle.cancel()
    vim.wait(200)
    assert.equals(0, result.code)
    for _, c in ipairs(fake.calls) do
      assert.not_equals("kill", c[2])
    end
  end)

  it("a spawner that throws becomes a result with an error, not a raise", function()
    run_once.system = function()
      error("no such binary")
    end
    local result
    run_once.run("docker", { image = "x" }, nil, function(res)
      result = res
    end)
    vim.wait(500, function()
      return result ~= nil
    end)
    assert.equals(-1, result.code)
    assert.matches("no such binary", result.error)
  end)

  it("bad options come back through on_exit", function()
    local result
    run_once.run("docker", {}, nil, function(res)
      result = res
    end)
    vim.wait(500, function()
      return result ~= nil
    end)
    assert.equals(-1, result.code)
    assert.matches("image", result.error)
  end)

  it("the use case forwards to the engine", function()
    local got
    local engine = {
      run_once = function(o, l, e)
        got = { o, l, e }
        return { cancel = function() end }
      end,
    }
    local usecase = require("sandbox.core.usecases.containers.run_once")
    local h = usecase(engine, { image = "x" }, nil, function() end)
    assert.equals("x", got[1].image)
    assert.is_function(h.cancel)
  end)
end)
