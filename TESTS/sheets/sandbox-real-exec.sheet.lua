-- Real processes (exec, exec-once, on docker and on podman): the commands start the engine CLI by the path a user
-- meets. The CLIs are the recording stand-ins of `fakes` (TESTS/sheets/_real.lua): nothing of the plugin is replaced,
-- so `testing perf` sees each start. The steps are built from the table below: a sheet is data, but plain Lua (numeric
-- `for`) runs while it is read.

---{ the command after `:Sandbox `, the program, the words of its call in order, the buffer it leaves focused }
local C = {
  { "container exec sbx-web", "docker", "exec sbx-web sh", "sandbox.nvim://exec/sbx-web" },
  { "container exec sbx-web bash workdir=/tmp", "docker", "exec /tmp sbx-web bash", "sandbox.nvim://exec/sbx-web" },
  { "container exec-once sbx-web ls -la", "docker", "exec sbx-web ls -la" },
  { "engine set podman" },
  { "container exec sbx-web", "podman", "exec sbx-web", "sandbox.nvim://exec/sbx-web" },
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
  id = "sandbox.real-exec",
  feature = "sandbox.exec",
  title = "sandbox.nvim: exec and exec-once open a terminal on the engine CLI for real",
  sizes = { { rows = 40, cols = 160 } },
  fakes = { "docker", "podman" },
  steps = steps,
  manual = { "against a real engine: the shell opens inside the container, workdir=/tmp lands in /tmp (pwd)" },
}
