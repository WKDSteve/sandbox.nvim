-- Live check: engine switching, section 9 of ALL/manual-test-checklists/sandbox.md (get/set/reset, .sandboxrc
-- precedence, `E` in the container list). Fake engine CLIs (TESTS/sheets/_helpers.lua): docker and podman count as
-- installed, nothing is started.
return {
  id = "sandbox.engine",
  title = "sandbox.nvim: engine get/set/reset, .sandboxrc precedence, E cycles and re-renders the list",
  task = "sandbox.nvim/testblatt-bindings-checkliste",
  sizes = { { rows = 30, cols = 120 } },
  steps = {
    { lua = [[dofile(vim.fn.getcwd() .. "/TESTS/sheets/_helpers.lua")]] },

    { keys = ":Sandbox engine get<CR>" },
    {
      wait = [[_G.noted("Active engine: podman (detected)")]],
      note = "detected: podman is preferred when installed, and the source says so",
    },
    { expect = [[_G.saw("podman version")]], note = "detection asked whether the engine answers" },

    { keys = ":Sandbox engine set docker<CR>" },
    { wait = [[_G.noted("Active engine set to docker for this session")]] },
    { lua = [[_G.clear()]] },
    { keys = ":Sandbox container list<CR>", note = "the list now comes from the other engine" },
    { wait = [[_G.bufname() == "sandbox.nvim://container-list" and _G.text():find("sbx-web", 1, true) ~= nil]] },
    { expect = [[_G.listed("docker") == 1 and _G.listed("podman") == 0]] },
    { keys = ":Sandbox engine get<CR>" },
    { wait = [[_G.noted("Active engine: docker (session override (:Sandbox engine set))")]] },

    { keys = ":Sandbox engine reset<CR>" },
    { wait = [[_G.noted("Session engine override cleared; using podman")]] },
    { expect = [[vim.g.sandbox_engine == nil]] },

    {
      lua = [[_G.project = _G.tempdir(); _G.write(_G.project .. "/.sandboxrc", { "engine=docker" })
        vim.cmd.cd(_G.project)]],
      note = "a project whose .sandboxrc names docker",
    },
    { keys = ":Sandbox engine get<CR>" },
    { wait = [[_G.noted("Active engine: docker (.sandboxrc)")]] },
    { keys = ":Sandbox engine set nerdctl<CR>", note = "the session override beats .sandboxrc" },
    { keys = ":Sandbox engine get<CR>" },
    { wait = [[_G.noted("Active engine: nerdctl (session override (:Sandbox engine set))")]] },
    { keys = ":Sandbox engine reset<CR>" },
    { lua = [[vim.cmd.cd(_G.root)]] },

    { keys = ":Sandbox container list<CR>" },
    { wait = [[_G.bufname() == "sandbox.nvim://container-list" and _G.listed("podman") > 0]] },
    { lua = [[_G.clear()]] },
    { keys = "E", note = "podman -> nerdctl, in the declared order docker, podman, nerdctl" },
    { wait = [[_G.listed("nerdctl") == 1 and _G.text():find("sbx-web", 1, true) ~= nil]] },
    { expect = [[_G.bufname() == "sandbox.nvim://container-list" and vim.g.sandbox_engine == "nerdctl"]] },
    { keys = "E" },
    { wait = [[_G.listed("docker") == 1 and vim.g.sandbox_engine == "docker"]] },
    { keys = "E" },
    { wait = [[_G.listed("podman") == 1 and vim.g.sandbox_engine == "podman"]] },
    { keys = "EEE", note = "a second full cycle lands in the same place" },
    { wait = [[_G.listed("podman") == 2 and vim.g.sandbox_engine == "podman"]] },
    { expect = [[_G.listed("nerdctl") == 2 and _G.listed("docker") == 2]] },
    { expect = [[_G.bufname() == "sandbox.nvim://container-list"]], note = "re-rendered in place, still the list" },
    { expect = [[#_G.other_spawns == 0 or error(vim.inspect(_G.other_spawns))]], note = "no real process" },
  },
  manual = {
    "with two real engines installed: after :Sandbox engine set, :Sandbox container list shows the other "
      .. "engine's real containers",
  },
}
