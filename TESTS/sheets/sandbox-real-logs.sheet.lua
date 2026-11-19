-- Real processes (logs, logs-follow): `:Sandbox container logs` captures the CLI's output asynchronously,
-- logs-follow streams `logs -f` through vim.system and q stops it. The CLI is the recording stand-in of `fakes`
-- (TESTS/sheets/_real.lua): it prints nothing and exits at once, so the follow ends by itself too.
return {
  id = "sandbox.real-logs",
  feature = "sandbox.logs",
  title = "sandbox.nvim: logs and logs-follow start the engine CLI for real",
  task = "sandbox.nvim/manual-checklist-run",
  sizes = { { rows = 40, cols = 160 } },
  fakes = { "docker" },
  steps = {
    { lua = [[dofile(vim.fn.getcwd() .. "/TESTS/sheets/_real.lua")]] },
    { keys = ":Sandbox engine set docker<CR>" },
    { lua = "_G.fresh(); _G.m = _G.mark()" },
    { keys = ":Sandbox container logs sbx-web<CR>" },
    {
      wait = [[_G.ran("docker", "logs sbx-web", _G.m) and _G.bufname() == "sandbox.nvim://logs/sbx-web"]],
      note = "logs: one docker logs, its own buffer",
    },
    { lua = "_G.fresh(); _G.m = _G.mark()" },
    { keys = ":Sandbox container logs-follow sbx-web<CR>" },
    {
      wait = [[_G.ran("docker", "logs -f sbx-web", _G.m) and _G.bufname() == "sandbox.nvim://logs/sbx-web"]],
      note = "logs-follow: docker logs -f streams into the buffer",
    },
    { keys = "q", note = "q closes the follow" },
    { wait = [[_G.bufname() ~= "sandbox.nvim://logs/sbx-web"]] },
  },
  manual = { "against a real engine: logs-follow shows new lines live and q stops the docker process" },
}
