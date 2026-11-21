-- Real processes (:Sandbox wsl set-default/set-version/export/import/shutdown-all; the stand-in answers on every
-- system, a real wsl only on Windows): the commands start wsl by the path a user meets. The stand-in of `fakes`
-- (TESTS/sheets/_real.lua) prints nothing and exits 0: no distro is touched and no tarball is written. The steps are
-- built from the table below: a sheet is data, but plain Lua (numeric `for`) runs while it is read.

---{ the command after `:Sandbox `, the words of the wsl call in order, the toast that reports it }
-- set-version leaves its version out of the words: the Windows stand-in logs an argument with `echo arg=%~1>> log`,
-- and a lone digit there turns into a stream redirection (`2>>`), so the log never holds it. The toast names it.
local C = {
  { "wsl set-default sbx-wsl", "--set-default sbx-wsl", "Default WSL distro set to: sbx-wsl" },
  { "wsl set-version sbx-wsl 2", "--set-version sbx-wsl", "WSL distro sbx-wsl set to version 2" },
  { "wsl export sbx-wsl sbx-wsl.tar", "--export sbx-wsl sbx-wsl.tar", "exported to sbx-wsl.tar" },
  { "wsl import sbx-new sbx-dir sbx-wsl.tar", "--import sbx-new sbx-dir sbx-wsl.tar", "WSL distro imported: sbx-new" },
  { "wsl shutdown-all", "--shutdown", "WSL shut down" },
}

local steps = {
  { lua = [[dofile(vim.fn.getcwd() .. "/TESTS/sheets/_real.lua")]] },
}
for i = 1, #C do
  local cmd, words, toast = C[i][1], C[i][2], C[i][3]
  steps[#steps + 1] = { lua = "_G.fresh(); _G.m = _G.mark()" }
  steps[#steps + 1] = { wait = [[vim.fn.mode() == "n"]] }
  steps[#steps + 1] = { keys = ":Sandbox " .. cmd .. "<CR>" }
  steps[#steps + 1] = {
    wait = ("_G.ran(%q, %q, _G.m) and _G.noted(%q)"):format("wsl", words, toast),
    note = cmd .. ": wsl " .. words,
  }
end

return {
  id = "sandbox.real-wsl-ops",
  feature = "sandbox.wsl",
  title = "sandbox.nvim: :Sandbox wsl set-default, set-version, export, import and shutdown-all start wsl for real",
  task = "sandbox.nvim/restliche-blockierende-cli-aufrufe-und-erste",
  sizes = { { rows = 40, cols = 160 } },
  fakes = { "wsl" },
  steps = steps,
  manual = { "on Windows with a real WSL: export writes the tarball, import registers it as a new distro" },
}
