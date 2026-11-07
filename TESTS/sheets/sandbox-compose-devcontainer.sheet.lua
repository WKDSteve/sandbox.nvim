-- Live check: compose found from the cwd and the declared services read from the file (section 6 of
-- ALL/manual-test-checklists/sandbox.md), the devcontainer parser and its build/attach argv (section 7), from
-- projects in temp directories. Fake engine CLIs (TESTS/sheets/_helpers.lua): nothing is pulled or started.
return {
  id = "sandbox.compose-devcontainer",
  title = "sandbox.nvim: compose up/down/restart/ps/logs/services from the cwd, devcontainer build/attach/lazygit",
  task = "sandbox.nvim/manual-checklist-run",
  sizes = { { rows = 40, cols = 160 } },
  steps = {
    { lua = [[dofile(vim.fn.getcwd() .. "/TESTS/sheets/_helpers.lua")]] },
    { keys = ":Sandbox engine set docker<CR>" },
    {
      lua = [[_G.project = _G.tempdir() .. "/shop"
        _G.compose = _G.project .. "/compose.yml"
        _G.write(_G.compose, { "services:", "  web:", "    image: alpine", "    command: sleep 300" })
        vim.fn.mkdir(_G.project .. "/sub/deeper", "p")
        vim.cmd.cd(vim.fn.fnameescape(_G.project))
        -- the file the engine is handed, compared by its real path (a temp path can be spelled two ways)
        function _G.file_of(call)
          return call and vim.uv.fs_realpath(call.list[4]) == vim.uv.fs_realpath(_G.compose)
        end
        -- the one call so far ran `compose -f <the file> <verb>` (verb: "up -d", "down", ...)
        function _G.composed(verb)
          return #_G.calls == 1 and _G.file_of(_G.calls[1]) and table.concat(_G.calls[1].list, " ", 5) == verb
        end]],
      note = "a compose project with one service",
    },

    { lua = "_G.fresh()" },
    { keys = ":Sandbox compose services<CR>" },
    { wait = [[_G.bufname() == "sandbox.nvim://logs/compose-services" and _G.text() == "web"]] },
    { expect = [[#_G.calls == 0]], note = "read from the file: no engine call, no compose CLI" },
    { lua = [[_G.fail["docker"] = "Cannot connect to the Docker daemon"; _G.fresh()]], note = "the engine is down" },
    { keys = ":Sandbox compose services<CR>" },
    { wait = [[_G.bufname() == "sandbox.nvim://logs/compose-services" and _G.text() == "web"]] },
    { expect = [[#_G.calls == 0]], note = "still listed without an engine" },
    { keys = ":Sandbox compose ps<CR>", note = "ps needs the engine" },
    { wait = [[_G.noted("Failed to list compose services")]], note = "a readable error" },
    { lua = [[_G.fail = {}]] },

    { lua = "_G.fresh()" },
    { keys = ":Sandbox compose up<CR>" },
    { wait = [[_G.composed("up -d")]], note = "up -d on the file found in the cwd" },
    { lua = "_G.fresh()" },
    { keys = ":Sandbox compose down<CR>" },
    { wait = [[_G.composed("down")]] },
    { lua = "_G.fresh()" },
    { keys = ":Sandbox compose restart<CR>" },
    { wait = [[_G.composed("restart")]] },
    { lua = "_G.fresh()" },
    { keys = ":Sandbox compose ps<CR>" },
    { wait = [[_G.composed("ps") and _G.bufname() == "sandbox.nvim://logs/compose-ps"]] },
    { lua = "_G.fresh()" },
    { keys = ":Sandbox compose logs<CR>" },
    { wait = [[_G.composed("logs") and _G.bufname() == "sandbox.nvim://logs/compose-logs"]] },

    { lua = [[_G.fresh(); vim.cmd.cd("sub/deeper")]], note = "deeper inside the project tree" },
    { keys = ":Sandbox compose up<CR>" },
    { wait = [[_G.composed("up -d")]], note = "walks up to the project's file" },
    { lua = [[_G.fresh(); vim.cmd.cd(vim.fn.fnameescape(_G.tempdir()))]], note = "outside any compose project" },
    { keys = ":Sandbox compose up<CR>" },
    { wait = [[_G.noted("No docker-compose.yml/compose.yml/podman-compose.yml found in cwd or an ancestor")]] },
    { expect = [[#_G.calls == 0]], note = "fails cleanly, nothing run" },

    {
      lua = [[_G.write(_G.compose, { "services:", "  - web" })
        vim.cmd.cd(vim.fn.fnameescape(_G.project))
        _G.fresh()]],
      note = "services: as a YAML list",
    },
    { keys = ":Sandbox compose services<CR>" },
    { wait = [[_G.noted("'services:' is a list, not a map of service name -> config")]] },

    {
      lua = [[_G.dev = _G.tempdir() .. "/my proj"
        _G.write(_G.dev .. "/.devcontainer/devcontainer.json", {
          "{",
          "  // JSONC: a comment and a trailing comma",
          '  "image": "alpine",',
          '  "workspaceFolder": "/workspace",',
          "}",
        })
        vim.cmd.cd(vim.fn.fnameescape(_G.dev))
        _G.fresh()
        -- the second call ran the image with the workspace bind-mounted at workspaceFolder
        function _G.started()
          local l = _G.calls[2] and _G.calls[2].list or {}
          local host = (l[7] or ""):match("^(.*):/workspace$")
          return #_G.calls == 2 and table.concat(l, " ", 1, 6) == "docker run -d --name sandbox-devcontainer-my_proj -v"
            and host ~= nil and vim.uv.fs_realpath(host) == vim.uv.fs_realpath(_G.dev) and l[8] == "alpine"
        end]],
      note = "a devcontainer.json with a comment and a trailing comma, in a folder with a space",
    },
    { keys = ":Sandbox devcontainer build<CR>" },
    { wait = [[_G.noted("Devcontainer ready. Run :Sandbox devcontainer attach to open a shell.")]] },
    { expect = [[_G.calls[1].argv == "docker pull alpine"]], note = "a plain image is pulled" },
    {
      expect = [[_G.started()]],
      note = "started with the workspace bind-mounted at workspaceFolder, named after the folder",
    },
    { lua = "_G.fresh()" },
    { keys = ":Sandbox devcontainer attach<CR>" },
    { wait = [[_G.only_call("docker exec -it sandbox-devcontainer-my_proj sh", "term")]] },
    { lua = "_G.fresh()" },
    { keys = ":Sandbox devcontainer lazygit<CR>", note = "gitsuite.nvim is not on this runtimepath" },
    { wait = [[_G.noted("gitsuite.nvim is not installed -- install")]] },
    { expect = [[#_G.calls == 0 and #_G.other_spawns == 0]], note = "only the error, nothing started" },

    {
      lua = [[_G.write(_G.dev .. "/.devcontainer/compose.yml", { "services:", "  app:", "    image: alpine" })
        _G.write(_G.dev .. "/.devcontainer/devcontainer.json", {
          '{ "dockerComposeFile": "compose.yml", "service": "app", "workspaceFolder": "/workspace" }',
        })
        _G.fresh()
        function _G.dev_composed()
          local l = _G.calls[#_G.calls].list
          return vim.uv.fs_realpath(l[4]) == vim.uv.fs_realpath(_G.dev .. "/.devcontainer/compose.yml") and l[5] == "up"
        end]],
      note = "a compose-based devcontainer",
    },
    { keys = ":Sandbox devcontainer build<CR>" },
    { wait = [[_G.last("docker compose -f") ~= nil]] },
    {
      expect = [[_G.dev_composed()]],
      note = "build hands over to compose up on the referenced file",
    },
    { lua = [[vim.cmd.cd(vim.fn.fnameescape(_G.root))]] },
    { expect = [[#_G.other_spawns == 0 or error(vim.inspect(_G.other_spawns))]], note = "no real process" },
  },
  manual = {
    "against a real engine: compose up really starts the service, down removes (not only stops) it, "
      .. "the statusline shows the progress of up",
    "devcontainer attach lands in /workspace with the real project files (a file touched inside shows on the host)",
    "merge-conflict preflight with gitsuite.nvim: an unresolved conflict aborts the build; without gitsuite.nvim "
      .. "the build runs and :checkhealth sandbox reports the preflight as skipped",
    "devcontainer lazygit with gitsuite.nvim opens lazygit for the host workspace",
  },
}
