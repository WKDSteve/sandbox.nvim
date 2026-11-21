-- Real processes (image tag/inspect/history/save/load, volume and network create/inspect, network connect/disconnect,
-- compose ps/logs, registry login): the commands start the engine CLI by the path a user meets. No engine is pinned,
-- so the first command also finds the engine (`podman version`, once per session). The CLIs are the recording
-- stand-ins of `fakes` (TESTS/sheets/_real.lua): they print nothing and exit 0, nothing is written, no registry is
-- reached. The steps are built from the table below: a sheet is data, but plain Lua (numeric `for`) runs while it is
-- read.

---{ the command after `:Sandbox `, the program, the words of its call in order }
local C = {
  { "image tag alpine:edge sbx:t", "podman", "tag alpine:edge sbx:t" },
  { "image inspect alpine:edge", "podman", "inspect alpine:edge" },
  { "image history alpine:edge", "podman", "history alpine:edge" },
  { "image save alpine:edge sbx-img.tar", "podman", "save -o sbx-img.tar alpine:edge" },
  { "image load sbx-img.tar", "podman", "load -i sbx-img.tar" },
  { "volume create sbx-vol", "podman", "volume create sbx-vol" },
  { "volume inspect sbx-vol", "podman", "volume inspect sbx-vol" },
  { "network create sbx-net", "podman", "network create sbx-net" },
  { "network inspect sbx-net", "podman", "network inspect sbx-net" },
  { "network connect sbx-net sbx-c", "podman", "network connect sbx-net sbx-c" },
  { "network disconnect sbx-net sbx-c", "podman", "network disconnect sbx-net sbx-c" },
}

local steps = {
  { lua = [[dofile(vim.fn.getcwd() .. "/TESTS/sheets/_real.lua")]] },
}
for i = 1, #C do
  local cmd, program, words = C[i][1], C[i][2], C[i][3]
  steps[#steps + 1] = { lua = "_G.fresh(); _G.m = _G.mark()" }
  steps[#steps + 1] = { wait = [[vim.fn.mode() == "n"]] }
  steps[#steps + 1] = { keys = ":Sandbox " .. cmd .. "<CR>" }
  steps[#steps + 1] =
    { wait = ("_G.ran(%q, %q, _G.m)"):format(program, words), note = cmd .. ": " .. program .. " " .. words }
  if i == 1 then
    steps[#steps + 1] = {
      wait = [[_G.ran("podman", "version")]],
      note = "the first command found the engine: podman is preferred and answered its version probe",
    }
  end
end

local tail = {
  {
    lua = [[_G.fresh()
      _G.dev = vim.fs.normalize(vim.fn.tempname()) .. "/shop"
      vim.fn.mkdir(_G.dev, "p")
      vim.fn.writefile({ "services:", "  web:", "    image: alpine" }, _G.dev .. "/compose.yml")
      vim.cmd.cd(vim.fn.fnameescape(_G.dev))
      _G.m = _G.mark()]],
    note = "a compose project in a temp directory",
  },
  { keys = ":Sandbox compose ps<CR>" },
  {
    wait = [[_G.ran("podman", "compose -f", _G.m) and _G.ran("podman", "ps", _G.m)
    and _G.bufname() == "sandbox.nvim://logs/compose-ps"]],
    note = "compose ps: the list lands in a view",
  },
  { lua = "_G.fresh(); _G.m = _G.mark()" },
  { keys = ":Sandbox compose logs<CR>" },
  { wait = [[_G.ran("podman", "logs", _G.m) and _G.bufname() == "sandbox.nvim://logs/compose-logs"]] },
  { lua = [[_G.fresh(); vim.cmd.cd(vim.fn.fnameescape(_G.root)); _G.m = _G.mark()]] },

  { input = ":Sandbox registry login ghcr.io<CR>", note = "input: keys would end its insert mode" },
  { wait = [[_G.asks("Registry username")]], note = "login asks for the user name" },
  { input = "sbx-user<CR>" },
  { wait = [[_G.asks("Registry password")]] },
  { input = "sbx-secret<CR>" },
  {
    wait = [[_G.ran("podman", "login --username sbx-user --password-stdin ghcr.io", _G.m)
      and _G.noted("Logged in to ghcr.io")]],
    note = "the password goes by stdin, never on the command line",
  },
  { expect = [[not _G.ran("podman", "sbx-secret", _G.m)]] },
  { lua = [[vim.cmd("stopinsert")]] },
}
for i = 1, #tail do
  steps[#steps + 1] = tail[i]
end

return {
  id = "sandbox.real-resource-ops",
  feature = "sandbox.resources",
  title = "sandbox.nvim: image, volume, network, compose and registry operations start the engine CLI for real",
  task = "sandbox.nvim/restliche-blockierende-cli-aufrufe-und-erste",
  sizes = { { rows = 40, cols = 160 } },
  fakes = { "docker", "podman" },
  steps = steps,
  manual = { "against a real engine: save writes the tarball, load reads it back, login stores the credentials" },
}
