-- Real processes (devcontainer): in a project with .devcontainer/devcontainer.json, build pulls the image and starts
-- the container, attach opens a shell in it. The CLI is the recording stand-in of `fakes` (TESTS/sheets/_real.lua).
return {
  id = "sandbox.real-devcontainer",
  feature = "sandbox.devcontainer",
  title = "sandbox.nvim: devcontainer build and attach start the engine CLI for real",
  task = "sandbox.nvim/manual-checklist-run",
  sizes = { { rows = 30, cols = 120 } },
  fakes = { "docker" },
  steps = {
    { lua = [[dofile(vim.fn.getcwd() .. "/TESTS/sheets/_real.lua")]] },
    { keys = ":Sandbox engine set docker<CR>" },
    {
      lua = [[_G.dev = vim.fs.normalize(vim.fn.tempname()) .. "/my_proj"
        vim.fn.mkdir(_G.dev .. "/.devcontainer", "p")
        vim.fn.writefile({ '{ "image": "alpine", "workspaceFolder": "/workspace" }' },
          _G.dev .. "/.devcontainer/devcontainer.json")
        vim.cmd.cd(vim.fn.fnameescape(_G.dev))
        _G.m = _G.mark()]],
      note = "a project with a devcontainer.json on a plain image",
    },
    { keys = ":Sandbox devcontainer build<CR>" },
    { wait = [[_G.noted("Devcontainer ready. Run :Sandbox devcontainer attach to open a shell.")]] },
    { expect = [[_G.must("docker", "pull alpine", _G.m)]], note = "the image is pulled" },
    { expect = [[_G.must("docker", "run -d --name sandbox-devcontainer-my_proj", _G.m)]], note = "and run" },
    { lua = "_G.fresh(); _G.m = _G.mark()" },
    { keys = ":Sandbox devcontainer attach<CR>" },
    {
      wait = [[_G.ran("docker", "exec sandbox-devcontainer-my_proj", _G.m) and vim.bo.buftype == "terminal"]],
      note = "attach: a shell in a terminal buffer",
    },
    { lua = [[vim.cmd("stopinsert"); vim.cmd.cd(vim.fn.fnameescape(_G.root))]] },
  },
  manual = { "against a real engine: build starts the container with the workspace mounted, attach lands in it" },
}
