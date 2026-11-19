-- Real processes (engine detection, the container list): with no engine pinned, `:Sandbox engine get` asks the
-- preferred installed engine whether it answers (`podman version`, once per session), and the list of the engine set
-- at runtime runs its `ps`. The CLIs are the recording stand-ins of `fakes` (TESTS/sheets/_real.lua): both count as
-- installed and both answer.
return {
  id = "sandbox.real-engine",
  feature = "sandbox.engine",
  title = "sandbox.nvim: engine detection probes the CLI for real, once per session",
  task = "sandbox.nvim/manual-checklist-run",
  sizes = { { rows = 30, cols = 120 } },
  fakes = { "docker", "podman" },
  steps = {
    { lua = [[dofile(vim.fn.getcwd() .. "/TESTS/sheets/_real.lua")]] },
    { keys = ":Sandbox engine get<CR>" },
    {
      wait = [[_G.noted("Active engine: podman (detected)") and _G.ran("podman", "version")]],
      note = "detected: podman is preferred and answered its version probe",
    },
    { lua = "_G.m = _G.mark()" },
    { keys = ":Sandbox engine get<CR>" },
    { expect = [[not _G.ran("podman", "version", _G.m)]], note = "the probe's answer is kept for the session" },
    { keys = ":Sandbox engine reset<CR>", note = "reset forgets it" },
    { wait = [[_G.noted("Session engine override cleared; using podman") and _G.ran("podman", "version", _G.m)]] },
  },
  manual = { "with a stopped podman VM beside a running docker: detection falls through to docker" },
}
