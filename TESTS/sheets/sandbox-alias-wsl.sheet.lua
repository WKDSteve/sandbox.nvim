-- Live check: `:Sbx` is `:Sandbox` (every route of the `:Sbx` section of the bindings checklist, nvim-config
-- docs/ROADMAP/Final_Checks/BINDINGS-RUNTIME-CHECKLIST.md, reaches the engine with the same argv), and the
-- `:Sandbox wsl ...` routes. The wsl namespace exists only where wsl.exe is reachable; here the fake says it is and
-- the commands are registered again, so it runs on every platform. Fake CLIs (TESTS/sheets/_helpers.lua): no
-- container, no distro is touched.

---Every `:Sbx` route that runs without a prompt, with the argv `:Sandbox` hands the engine for the same words.
local SAME = {
  "container list",
  "container exec sbx-web workdir=/tmp",
  "container logs sbx-web",
  "container cp sbx-web:/a ./a",
  "container top sbx-web",
  "container stats sbx-web",
  "container inspect sbx-web",
  "container rename sbx-web sbx-new",
  "container pause sbx-web",
  "container unpause sbx-web",
  "container exec-once sbx-web workdir=/tmp ls",
  "image list",
  "image pull alpine",
  "image push alpine:edge",
  "image inspect alpine:edge",
  "image history alpine:edge",
  "image load ./a.tar",
  "image tag alpine:edge my/alpine:1",
  "image build sbx-img .",
  "image save alpine:edge ./a.tar",
  "volume list",
  "volume create sbx-vol",
  "volume inspect sbx-vol",
  "network list",
  "network create sbx-net",
  "network inspect sbx-net",
  "network connect sbx-net sbx-web",
  "network disconnect sbx-net sbx-web",
  "compose services",
  "compose ps",
  "compose logs",
  "compose up",
  "registry logout",
  "devcontainer build",
  "devcontainer attach",
  "devcontainer lazygit",
  "wsl list",
  "wsl start sbx-wsl",
  "wsl exec sbx-wsl echo hello",
  "wsl set-default sbx-wsl",
  "wsl set-version sbx-wsl 1",
  "wsl export sbx-wsl ./d.tar",
  "wsl import sbx-new ./disk ./d.tar",
}

---{ the `:Sandbox wsl` command, the argv wsl.exe must see, how it is run, the buffer it leaves focused }
local WSL = {
  { "wsl list", "wsl --list --verbose", "blocking", "sandbox.nvim://wsl-list" },
  { "wsl start sbx-wsl", "wsl -d sbx-wsl -- echo", "blocking" },
  { "wsl stop sbx-wsl", "wsl --terminate sbx-wsl", "blocking" },
  { "wsl exec sbx-wsl echo hello", "wsl -d sbx-wsl -- echo hello", "term", "sandbox.nvim://wsl/sbx-wsl" },
  { "wsl set-default sbx-wsl", "wsl --set-default sbx-wsl", "blocking" },
  { "wsl set-version sbx-wsl 1", "wsl --set-version sbx-wsl 1", "blocking" },
  { "wsl export sbx-wsl ./d.tar", "wsl --export sbx-wsl ./d.tar", "blocking" },
  { "wsl import sbx-new ./disk ./d.tar", "wsl --import sbx-new ./disk ./d.tar", "blocking" },
  { "wsl shutdown-all", "wsl --shutdown", "blocking" },
}

local steps = {
  { lua = [[dofile(vim.fn.getcwd() .. "/TESTS/sheets/_helpers.lua")]] },
  {
    lua = [[_G.installed.wsl = true
      require("sandbox.bindings.usrcmds").setup()
      require("sandbox.config").options.confirm_destructive = false
      _G.project = _G.tempdir()
      _G.write(_G.project .. "/compose.yml", { "services:", "  web:", "    image: alpine" })
      _G.write(_G.project .. "/.devcontainer/devcontainer.json", { '{ "image": "alpine" }' })
      vim.cmd.cd(vim.fn.fnameescape(_G.project))
      -- what `:<verb> <words>` did: the argv of each call, the buffer it left focused, its last toast
      function _G.argvs_of(verb, words)
        _G.fresh()
        vim.cmd(verb .. " " .. words)
        vim.wait(100)
        vim.cmd("stopinsert")
        local seen = vim.tbl_map(function(c) return c.via .. " " .. c.argv end, _G.calls)
        local toasts = require("lib.nvim.notify.popup").history("sandbox")
        seen[#seen + 1] = "buffer " .. _G.bufname()
        seen[#seen + 1] = "toast " .. tostring(toasts[#toasts] and toasts[#toasts].message)
        return seen
      end]],
    note = "wsl.exe reachable (faked), the routes registered again; a compose and a devcontainer project",
  },
  { keys = ":Sbx engine set docker<CR>", note = ":Sbx engine set" },
  { wait = [[_G.noted("Active engine set to docker for this session")]] },
  { keys = ":Sbx engine get<CR>" },
  { wait = [[_G.noted("Active engine: docker (session override (:Sandbox engine set))")]] },
  {
    lua = [[_G.diff = {}
      for _, words in ipairs(_G.same) do
        local a, b = _G.argvs_of("Sandbox", words), _G.argvs_of("Sbx", words)
        if not vim.deep_equal(a, b) then
          _G.diff[#_G.diff + 1] = words .. ": " .. table.concat(a, "; ") .. " vs " .. table.concat(b, "; ")
        end
      end]],
    note = "each route through both names",
  },
  { expect = [[#_G.diff == 0 or error(table.concat(_G.diff, " | "), 0)]] },
  { lua = "_G.fresh()" },
  { keys = ":Sbx docs generate<CR>" },
  { wait = [[_G.noted("Generated docs/GENERATED_COMMANDS.md")]] },
  { lua = "_G.fresh()" },
  { input = ":Sbx container run<CR>", note = "the run wizard (input: keys would end its insert mode)" },
  { wait = [[_G.asks("Image")]] },
  { input = "<Esc>" },
  { lua = [[vim.cmd("stopinsert")]] },
  { wait = [[_G.noted("Aborted: no image given") and not _G.in_float()]] },
  { lua = "_G.fresh()" },
  { input = ":Sbx registry login ghcr.io<CR>" },
  { wait = [[_G.asks("username")]] },
  { input = "sbx-user<CR>" },
  { wait = [[_G.asks("password")]] },
  { input = "pw<CR>" },
  { wait = [[_G.only_call("docker login --username sbx-user --password-stdin ghcr.io", "blocking")]] },
  { wait = [[_G.noted("Logged in to ghcr.io")]] },
  { lua = [[vim.cmd("stopinsert")]] },
  {
    expect = [[vim.deep_equal(vim.fn.getcompletion("Sandbox wsl ", "cmdline"), { "exec", "export", "import", "list",
      "set-default", "set-version", "shutdown-all", "start", "stop" })
      or error(vim.inspect(vim.fn.getcompletion("Sandbox wsl ", "cmdline")), 0)]],
    note = ":Sandbox wsl<Tab> offers the wsl verbs",
  },
}
for i = 1, #WSL do
  local cmd, argv, via, buf = WSL[i][1], WSL[i][2], WSL[i][3], WSL[i][4]
  steps[#steps + 1] = { lua = "_G.fresh()" }
  steps[#steps + 1] = { wait = [[vim.fn.mode() == "n"]] }
  steps[#steps + 1] = { keys = ":Sandbox " .. cmd .. "<CR>" }
  local check = ("_G.only_call(%q, %q)"):format(argv, via)
  if buf then
    check = check .. (" and _G.bufname() == %q"):format(buf)
  end
  steps[#steps + 1] = { wait = check }
end
local tail = {
  { lua = [[vim.cmd("stopinsert"); vim.cmd.cd(vim.fn.fnameescape(_G.root))]] },
  { expect = [[#_G.other_spawns == 0 or error(vim.inspect(_G.other_spawns))]], note = "no real process" },
}
for i = 1, #tail do
  steps[#steps + 1] = tail[i]
end

-- The table of words reaches the child through its first step: the sheet is data, the child has its own Lua.
-- (No `table.concat`: a sheet is read with an empty environment, so only operators and string methods exist.)
local words = ""
for i = 1, #SAME do
  words = words .. ("%q, "):format(SAME[i])
end
steps[1] = { lua = [[dofile(vim.fn.getcwd() .. "/TESTS/sheets/_helpers.lua"); _G.same = { ]] .. words .. "}" }

return {
  id = "sandbox.alias-wsl",
  title = "sandbox.nvim: :Sbx runs every route :Sandbox runs, the same argv; the :Sandbox wsl routes",
  task = "sandbox.nvim/testblatt-bindings-checkliste",
  sizes = { { rows = 40, cols = 160 } },
  steps = steps,
  manual = {
    "on Windows with a registered distro: :Sandbox wsl list matches `wsl --list --verbose` (wsl.exe may write "
      .. "UTF-16), start/stop/set-default/export really change the distro",
  },
}
