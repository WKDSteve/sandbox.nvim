-- Real processes (the container list): `:Sandbox container list` runs the engine's `ps`, E switches to the next
-- engine and lists again. The CLIs are the recording stand-ins of `fakes` (TESTS/sheets/_real.lua): they list no
-- container, the rows and their keys are the business of sandbox.list-keys.
return {
  id = "sandbox.real-list",
  feature = "sandbox.container-list",
  title = "sandbox.nvim: the container list runs ps for real, E lists the next engine",
  task = "sandbox.nvim/manual-checklist-run",
  sizes = { { rows = 30, cols = 120 } },
  fakes = { "docker", "podman" },
  steps = {
    { lua = [[dofile(vim.fn.getcwd() .. "/TESTS/sheets/_real.lua")]] },
    { keys = ":Sandbox engine set docker<CR>" },
    { lua = "_G.m = _G.mark()" },
    { keys = ":Sandbox container list<CR>" },
    {
      wait = [[_G.ran("docker", "ps -a", _G.m) and _G.bufname() == "sandbox.nvim://container-list"]],
      note = "docker ps -a fills the list",
    },
    { lua = "_G.m = _G.mark()" },
    { keys = "E", note = "the next engine" },
    { wait = [[_G.ran("podman", "ps -a", _G.m)]], note = "podman ps -a lists again" },
    { keys = "q" },
  },
  manual = { "against a real engine: one row per container, its status color, the row keys act on it" },
}
