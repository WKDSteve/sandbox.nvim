--- The docker, podman and nerdctl adapters share one definition per verb (`sandbox.adapters.cli.*`); an engine's
--- own file exists only where its CLI really differs. This pins that split, so the next verb is not copied three
--- times again and the next difference does not hide inside a copy:
---
---   * every file of `docker/` has a shared module of the same name under `cli/`, and every engine has the same
---     set of files (the old spelling `inspect_containers` of podman is gone);
---   * an engine file delegates (`require("sandbox.adapters.cli.…").new("<engine>")`) unless it is listed here
---     as an override, and an override is a real difference (podman's flag, its JSON, its terminal);
---   * the shared module builds for the binary it is given (`new("x")` puts `x` in the argv, not `docker`).

local fake_run_argv = require("TESTS.sandbox.helpers.fake_run_argv")

local ENGINES = { "docker", "podman", "nerdctl" }

-- Where an engine's CLI is not the docker CLI. Anything not listed delegates.
local OVERRIDES = {
  podman = {
    ["containers.stop_container"] = true, -- `--timeout 1`, not `--time=1`
    ["containers.list_containers"] = true, -- one JSON array, not a line per container
    ["images.list_images"] = true, -- the same for images
    ["containers.exec_in_container"] = true, -- the terminal is set up in a different order
  },
}

local function root()
  return (vim.fn.getcwd():gsub("\\", "/")) .. "/lua/sandbox/adapters"
end

--- Every module of an engine directory, as `containers.stop_container`.
local function modules_of(dir)
  local out = {}
  for _, file in ipairs(vim.fn.glob(root() .. "/" .. dir .. "/**/*.lua", false, true)) do
    local rel = file:gsub("\\", "/"):sub(#root() + #dir + 3):gsub("%.lua$", ""):gsub("/", ".")
    out[#out + 1] = rel
  end
  table.sort(out)
  return out
end

local function read(path)
  local fd = assert(io.open(path, "rb"))
  local text = fd:read("*a")
  fd:close()
  return text
end

describe("the docker-CLI engines share one definition per verb", function()
  it("has the same modules in every engine, and a shared module for each", function()
    local docker = modules_of("docker")
    assert.is_true(#docker > 40, "docker has its modules")
    for _, engine in ipairs(ENGINES) do
      assert.same(docker, modules_of(engine), engine .. " has the modules docker has, no more and no fewer")
    end
    local shared = {}
    for _, name in ipairs(modules_of("cli")) do
      shared[name] = true
    end
    for _, name in ipairs(docker) do
      assert.is_true(shared[name] == true, "cli/ has no shared module for " .. name)
    end
  end)

  it("delegates in every engine file except the listed overrides, which are real differences", function()
    for _, engine in ipairs(ENGINES) do
      for _, name in ipairs(modules_of(engine)) do
        local text = read(root() .. "/" .. engine .. "/" .. name:gsub("%.", "/") .. ".lua")
        local delegates = text:find('require("sandbox.adapters.cli.' .. name .. '").new("' .. engine .. '")', 1, true)
          ~= nil
        local override = OVERRIDES[engine] and OVERRIDES[engine][name]
        if override then
          assert.is_false(delegates, engine .. "." .. name .. " is an override and must not delegate")
          assert.is_truthy(text:find('"' .. engine .. '"', 1, true), engine .. "." .. name .. " names its own binary")
        else
          assert.is_true(
            delegates,
            engine .. "." .. name .. " is a copy: delegate to cli." .. name .. " or list it as an override"
          )
        end
      end
    end
  end)

  it("builds the argv for the binary it is given", function()
    local state = fake_run_argv.install({ ok = true, output = "" })
    fake_run_argv.reload_prefix("sandbox.adapters.")
    local up = require("sandbox.adapters.cli.compose.up").new("fakeengine")
    up.up("c.yml", function() end)
    assert.same({ "fakeengine", "compose", "-f", "c.yml", "up", "-d" }, state.calls[1].cmd)
    fake_run_argv.reset()
    fake_run_argv.reload_prefix("sandbox.adapters.")
  end)
end)
