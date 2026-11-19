-- Real processes (:Sandbox wsl; the stand-in answers on every system, a real wsl only on Windows): the commands start
-- the engine CLI by the path a user meets. The CLIs are the recording stand-ins of `fakes` (TESTS/sheets/_real.lua):
-- nothing of the plugin is replaced, so `testing perf` sees each start. The steps are built from the table below: a
-- sheet is data, but plain Lua (numeric `for`) runs while it is read.

---{ the command after `:Sandbox `, the program, the words of its call in order, the buffer it leaves focused }
local C = {
  { "wsl list", "wsl", "--list --verbose" },
  { "wsl start sbx-wsl", "wsl", "-d sbx-wsl" },
  { "wsl exec sbx-wsl", "wsl", "-d sbx-wsl", "sandbox.nvim://wsl/sbx-wsl" },
  { "wsl stop sbx-wsl", "wsl", "--terminate sbx-wsl" },
}

local steps = {
  { lua = [[dofile(vim.fn.getcwd() .. "/TESTS/sheets/_real.lua")]] },
}
for i = 1, #C do
  local cmd, program, words, buf = C[i][1], C[i][2], C[i][3], C[i][4]
  steps[#steps + 1] = { lua = "_G.fresh(); _G.m = _G.mark()" }
  steps[#steps + 1] = { wait = [[vim.fn.mode() == "n"]] }
  steps[#steps + 1] = { keys = ":Sandbox " .. cmd .. "<CR>" }
  if program then
    local check = ("_G.ran(%q, %q, _G.m)"):format(program, words)
    if buf then
      check = check .. (" and _G.bufname() == %q"):format(buf)
    end
    steps[#steps + 1] = { wait = check, note = cmd .. ": " .. program .. " " .. words }
  end
end

return {
  id = "sandbox.real-wsl",
  feature = "sandbox.wsl",
  title = "sandbox.nvim: :Sandbox wsl list, start, exec and stop start wsl for real",
  task = "sandbox.nvim/manual-checklist-run",
  sizes = { { rows = 40, cols = 160 } },
  fakes = { "wsl" },
  steps = steps,
  manual = { "on Windows with a real WSL: list shows the distros, exec opens a shell inside the distro" },
}
