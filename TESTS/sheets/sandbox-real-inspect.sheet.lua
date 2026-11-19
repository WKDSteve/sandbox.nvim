-- Real processes (inspect, stats, top, cp): the commands start the engine CLI by the path a user meets. The CLIs are
-- the recording stand-ins of `fakes` (TESTS/sheets/_real.lua): nothing of the plugin is replaced, so `testing perf`
-- sees each start. The steps are built from the table below: a sheet is data, but plain Lua (numeric `for`) runs while
-- it is read.

---{ the command after `:Sandbox `, the program, the words of its call in order, the buffer it leaves focused }
local C = {
  { "container inspect sbx-web", "docker", "inspect sbx-web", "sandbox.nvim://inspect/sbx-web" },
  { "container stats sbx-web", "docker", "stats sbx-web", "sandbox.nvim://logs/stats/sbx-web" },
  { "container top sbx-web", "docker", "top sbx-web", "sandbox.nvim://logs/top/sbx-web" },
  { "container cp sbx-web:/etc/hostname ./h.txt", "docker", "cp sbx-web:/etc/hostname ./h.txt" },
}

local steps = {
  { lua = [[dofile(vim.fn.getcwd() .. "/TESTS/sheets/_real.lua")]] },
  { keys = ":Sandbox engine set docker<CR>" },
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
  id = "sandbox.real-inspect",
  feature = "sandbox.inspect",
  title = "sandbox.nvim: inspect, stats, top and cp start the engine CLI for real",
  task = "sandbox.nvim/manual-checklist-run",
  sizes = { { rows = 40, cols = 160 } },
  fakes = { "docker" },
  steps = steps,
  manual = {
    "against a real engine: inspect shows the JSON, stats and top real numbers, cp copies a file with its content",
  },
}
