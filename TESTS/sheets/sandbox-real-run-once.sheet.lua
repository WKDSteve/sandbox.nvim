-- Real processes (run_once, the headless API): a caller such as `testing ci --on=linux` runs a container once,
-- attached; cancel() stops the container, not only the CLI: `kill`, then `rm -f`, and `rm -f` again when the CLI
-- has ended (the cancelled CLI is killed before its stand-in writes its log). The CLI is the recording stand-in of
-- `fakes` (TESTS/sheets/_real.lua); the caller is a `lua` step, as the API has no command. `kill` and the `rm -f` of
-- the ended CLI overlap: on Windows two `.cmd` stand-ins appending to one log at once can lose a call (testing.nvim
-- task fake-programs-gleichzeitige-aufrufe-unter-windows-verlieren), so a step asks for one of them.
return {
  id = "sandbox.real-run-once",
  feature = "sandbox.run-once",
  title = "sandbox.nvim: run_once starts docker run --rm, cancel kills and removes the container",
  task = "sandbox.nvim/manual-checklist-run",
  sizes = { { rows = 24, cols = 100 } },
  fakes = { "docker" },
  steps = {
    { lua = [[dofile(vim.fn.getcwd() .. "/TESTS/sheets/_real.lua")]] },
    {
      lua = [[_G.result = nil
        local run_once = require("sandbox.core.usecases.containers.run_once")
        local engine = require("sandbox.adapters.docker.engine")
        local h = run_once(engine, { image = "alpine", name = "sbx-once", command = { "true" } }, nil, function(r)
          _G.result = r
        end)
        h.cancel()]],
      note = "start a run and cancel it at once",
    },
    { wait = [[_G.result ~= nil and _G.result.cancelled == true]], note = "the exit is reported once, cancelled" },
    {
      wait = [[_G.ran("docker", "kill sbx-once") or _G.ran("docker", "rm -f sbx-once")]],
      note = "cancel stops the container (kill, rm -f); one of the overlapping calls may miss the stand-in log",
    },
    {
      lua = [[_G.result = nil
        local run_once = require("sandbox.core.usecases.containers.run_once")
        run_once(require("sandbox.adapters.docker.engine"), { image = "alpine", name = "sbx-once2" }, nil, function(r)
          _G.result = r
        end)]],
      note = "a run that ends by itself",
    },
    { wait = [[_G.result ~= nil and _G.result.code == 0 and not _G.result.cancelled]] },
    { expect = [[_G.must("docker", "run --rm --name sbx-once2")]], note = "attached, removed afterwards" },
  },
  manual = { "against a real engine: the output arrives line by line and no sandbox-once container is left" },
}
