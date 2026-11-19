-- Real processes (images, volumes, networks, registry): the commands start the engine CLI by the path a user meets. The
-- CLIs are the recording stand-ins of `fakes` (TESTS/sheets/_real.lua): nothing of the plugin is replaced, so `testing
-- perf` sees each start. The steps are built from the table below: a sheet is data, but plain Lua (numeric `for`) runs
-- while it is read.

---{ the command after `:Sandbox `, the program, the words of its call in order, the buffer it leaves focused }
local C = {
  { "image list", "docker", "images", "sandbox.nvim://image-list" },
  { "image remove alpine:edge", "docker", "rmi alpine:edge" },
  { "image prune -b", "docker", "image prune", "sandbox.nvim://term/image-prune" },
  { "volume list", "docker", "volume ls", "sandbox.nvim://volume-list" },
  { "volume remove sbx-vol", "docker", "volume rm sbx-vol" },
  { "network list", "docker", "network ls", "sandbox.nvim://network-list" },
  { "network remove sbx-net", "docker", "network rm sbx-net" },
  { "registry logout ghcr.io", "docker", "logout ghcr.io" },
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
  id = "sandbox.real-resources",
  feature = "sandbox.resources",
  title = "sandbox.nvim: image, volume, network and registry commands start the engine CLI for real",
  sizes = { { rows = 40, cols = 160 } },
  fakes = { "docker" },
  steps = steps,
  manual = { "against a real engine: the lists show the real images, volumes and networks; remove removes them" },
}
