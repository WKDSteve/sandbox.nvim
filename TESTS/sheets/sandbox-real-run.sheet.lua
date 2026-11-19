-- Real processes (the run wizard): `:Sandbox container run` asks for image, name, ports, volumes and env and starts
-- one `docker run -d` as a background job. The CLI is the recording stand-in of `fakes` (TESTS/sheets/_real.lua).
return {
  id = "sandbox.real-run",
  feature = "sandbox.run-wizard",
  title = "sandbox.nvim: the run wizard starts one docker run for real",
  sizes = { { rows = 40, cols = 160 } },
  fakes = { "docker" },
  steps = {
    { lua = [[dofile(vim.fn.getcwd() .. "/TESTS/sheets/_real.lua")]] },
    { keys = ":Sandbox engine set docker<CR>" },
    { lua = "_G.fresh(); _G.m = _G.mark()" },
    { input = ":Sandbox container run<CR>", note = "the run wizard (input: keys would end its insert mode)" },
    { wait = [[_G.asks("Image")]] },
    { input = "alpine<CR>" },
    { wait = [[_G.asks("Container name")]] },
    { input = "sbx-run<CR>" },
    { wait = [[_G.asks("Port mappings")]] },
    { input = "8080:80<CR>" },
    { wait = [[_G.asks("Volume mounts")]] },
    { input = "<CR>", note = "no volumes" },
    { wait = [[_G.asks("Env vars")]] },
    { input = "<CR>", note = "no env" },
    {
      wait = [[_G.ran("docker", "run -d --name sbx-run -p 8080:80 alpine", _G.m)]],
      note = "one docker run with what was typed",
    },
    { lua = [[vim.cmd("stopinsert")]] },
  },
  manual = { "against a real engine: the container runs and shows up in :Sandbox container list" },
}
