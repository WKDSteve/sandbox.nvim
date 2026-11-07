-- Live check: every `:Sandbox container ...` command of the bindings checklist (nvim-config
-- docs/ROADMAP/Final_Checks/BINDINGS-RUNTIME-CHECKLIST.md) and the `--buffer`/`-b` variants of section 2 of
-- ALL/manual-test-checklists/sandbox.md. Each command is typed and must reach the engine with exactly one argv, by
-- the path named (blocking/async capture, a background job, a terminal buffer or vim.system). Fake engine CLIs
-- (TESTS/sheets/_helpers.lua), `confirm_destructive = false`: nothing is started or removed.
--
-- The steps are built from the table below: a sheet is data, but plain Lua (numeric `for`, string methods) runs
-- while it is read.

---{ the command after `:Sandbox `, the argv the engine must see, how it is run, the buffer it leaves focused }
local C = {
  { "container logs sbx-web", "docker logs sbx-web", "async", "sandbox.nvim://logs/sbx-web" },
  { "container stats sbx-web", "docker stats --no-stream sbx-web", "async", "sandbox.nvim://logs/stats/sbx-web" },
  { "container top sbx-web", "docker top sbx-web", "async", "sandbox.nvim://logs/top/sbx-web" },
  { "container inspect sbx-web", "docker inspect sbx-web", "async", "sandbox.nvim://inspect/sbx-web" },
  { "container rename sbx-web sbx-new", "docker rename sbx-web sbx-new", "blocking" },
  { "container pause sbx-web", "docker pause sbx-web", "job" },
  { "container unpause sbx-web", "docker unpause sbx-web", "job" },
  { "container cp sbx-web:/etc/hostname ./h.txt", "docker cp sbx-web:/etc/hostname ./h.txt", "blocking" },
  { "container cp ./h.txt sbx-web:/tmp/h.txt", "docker cp ./h.txt sbx-web:/tmp/h.txt", "blocking" },
  { "container exec sbx-web", "docker exec -it sbx-web sh", "term", "sandbox.nvim://exec/sbx-web" },
  {
    "container exec sbx-web bash workdir=/tmp",
    "docker exec -it -w /tmp sbx-web bash",
    "term",
    "sandbox.nvim://exec/sbx-web",
  },
  { "container exec-once sbx-web workdir=/tmp ls -la", "docker exec -it -w /tmp sbx-web ls -la", "term" },
  { "container start sbx-db", "docker start sbx-db", "blocking" },
  { "container stop sbx-web", "docker stop --time=1 sbx-web", "job" },
  { "container kill sbx-web", "docker kill sbx-web", "job" },
  { "container restart sbx-web", "docker restart sbx-web", "job" },
  { "container remove sbx-db", "docker rm sbx-db", "job" },
  { "container prune", "docker container prune -f", "async" },
  { "container start sbx-db --buffer", "docker start sbx-db", "term", "sandbox.nvim://term/start/sbx-db" },
  { "container stop sbx-db -b", "docker stop --time=1 sbx-db", "term", "sandbox.nvim://term/stop/sbx-db" },
  { "container kill sbx-db -b", "docker kill sbx-db", "term", "sandbox.nvim://term/kill/sbx-db" },
  { "container restart sbx-db -b", "docker restart sbx-db", "term", "sandbox.nvim://term/restart/sbx-db" },
  { "container remove sbx-db -b", "docker rm sbx-db", "term", "sandbox.nvim://term/remove/sbx-db" },
  { "container prune -b", "docker container prune -f", "term", "sandbox.nvim://term/prune" },
}

local steps = {
  { lua = [[dofile(vim.fn.getcwd() .. "/TESTS/sheets/_helpers.lua")]] },
  { keys = ":Sandbox engine set docker<CR>" },
  { lua = [[require("sandbox.config").options.confirm_destructive = false]] },
}
for i = 1, #C do
  local cmd, argv, via, buf = C[i][1], C[i][2], C[i][3], C[i][4]
  steps[#steps + 1] = { lua = "_G.fresh()" }
  steps[#steps + 1] = { wait = [[vim.fn.mode() == "n"]] }
  steps[#steps + 1] = { keys = ":Sandbox " .. cmd .. "<CR>" }
  local check = ("_G.only_call(%q, %q)"):format(argv, via)
  if buf then
    check = check .. (" and _G.bufname() == %q"):format(buf)
  end
  steps[#steps + 1] = { wait = check }
  if via == "term" then
    steps[#steps + 1] = { expect = [[vim.bo.buftype == "terminal"]], note = cmd .. ": a terminal buffer" }
  end
end

local tail = {
  { lua = "_G.fresh()" },
  { wait = [[vim.fn.mode() == "n"]] },
  { keys = ":Sandbox container logs-follow sbx-web<CR>", note = "logs-follow streams through vim.system" },
  { wait = [[_G.only_call("docker logs -f sbx-web", "system") and _G.bufname() == "sandbox.nvim://logs/sbx-web"]] },
  { wait = [[_G.text():find("log line one of sbx-web", 1, true) ~= nil]], note = "the streamed lines arrive" },
  { keys = "q", note = "q stops the follow" },
  { wait = [[_G.kills > 0 and _G.buf("sandbox.nvim://logs/sbx-web") == nil]] },
  { lua = "_G.fresh(); _G.kills = 0" },
  { keys = ":Sandbox container logs-follow sbx-web<CR>" },
  { wait = [[_G.bufname() == "sandbox.nvim://logs/sbx-web"]] },
  { keys = ":bwipeout<CR>", note = "wiping the buffer instead of q" },
  { wait = [[_G.kills > 0]], note = "the BufWipeout safety net stops the stream too" },

  { lua = "_G.fresh()" },
  { input = ":Sandbox container run<CR>", note = "the run wizard (input: keys would end its insert mode)" },
  { wait = [[_G.asks("Image")]] },
  { input = "alpine<CR>" },
  { wait = [[_G.asks("Container name")]] },
  { input = "sbx-run<CR>" },
  { wait = [[_G.asks("Port mappings")]] },
  { input = "8080:80<CR>" },
  { wait = [[_G.asks("Volume mounts")]] },
  { input = "<CR>" },
  { wait = [[_G.asks("Env vars")]] },
  { input = "A=1,B=2<CR>" },
  {
    wait = [[_G.only_call("docker run -d --name sbx-run -p 8080:80 -e A=1 -e B=2 alpine", "job")]],
    note = "image, name, ports, volumes, env asked in that order, one run",
  },
  { lua = [[vim.cmd("stopinsert")]] },
  { expect = [[#_G.other_spawns == 0 or error(vim.inspect(_G.other_spawns))]], note = "no real process" },
}
for i = 1, #tail do
  steps[#steps + 1] = tail[i]
end

return {
  id = "sandbox.cmds-container",
  title = "sandbox.nvim: every :Sandbox container command reaches the engine with the argv it names",
  task = "sandbox.nvim/testblatt-bindings-checkliste",
  sizes = { { rows = 40, cols = 160 } },
  steps = steps,
  manual = {
    "against a real engine: container run starts a real container, exec lands in workdir=/tmp (pwd), "
      .. "logs-follow shows new lines live, cp round-trips a file with real content",
  },
}
