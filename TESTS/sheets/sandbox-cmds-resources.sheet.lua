-- Live check: every `:Sandbox image|volume|network|registry ...` command of the bindings checklist (nvim-config
-- docs/ROADMAP/Final_Checks/BINDINGS-RUNTIME-CHECKLIST.md), the keys of the image, volume and network lists
-- (sections 4 and 5 of ALL/manual-test-checklists/sandbox.md), and the pull of section 2: without `--buffer` one
-- start and one completion toast, no buffer. Fake engine CLIs (TESTS/sheets/_helpers.lua): nothing is pulled,
-- pushed, built or removed. `confirm_destructive = false` for the table, so remove and prune must not ask.

---{ the command after `:Sandbox `, the argv the engine must see, how it is run, the buffer it leaves focused }
local C = {
  { "image list", "docker images --format {{json .}}", "blocking", "sandbox.nvim://image-list" },
  { "image pull alpine --buffer", "docker pull alpine", "term", "sandbox.nvim://term/pull/alpine" },
  { "image push alpine:edge", "docker push alpine:edge", "async" },
  { "image tag alpine:edge my/alpine:1", "docker tag alpine:edge my/alpine:1", "blocking" },
  {
    "image build sbx-img:latest .",
    "docker build -t sbx-img:latest .",
    "term",
    "sandbox.nvim://term/build/sbx-img:latest",
  },
  { "image save alpine:edge ./a.tar", "docker save -o ./a.tar alpine:edge", "blocking" },
  { "image load ./a.tar", "docker load -i ./a.tar", "blocking" },
  {
    "image history alpine:edge",
    "docker history alpine:edge",
    "blocking",
    "sandbox.nvim://logs/image-history/alpine:edge",
  },
  { "image inspect alpine:edge", "docker inspect alpine:edge", "blocking", "sandbox.nvim://inspect/image-alpine:edge" },
  { "image remove alpine:edge", "docker rmi alpine:edge", "job" },
  { "image prune", "docker image prune -f", "async" },
  { "image prune -b", "docker image prune -f", "term", "sandbox.nvim://term/image-prune" },
  { "volume list", "docker volume ls --format {{json .}}", "blocking", "sandbox.nvim://volume-list" },
  { "volume create sbx-vol", "docker volume create sbx-vol", "blocking" },
  { "volume inspect sbx-vol", "docker volume inspect sbx-vol", "blocking", "sandbox.nvim://inspect/volume-sbx-vol" },
  { "volume remove sbx-vol", "docker volume rm sbx-vol", "job" },
  { "volume prune", "docker volume prune -f", "async" },
  { "network list", "docker network ls --format {{json .}}", "blocking", "sandbox.nvim://network-list" },
  { "network create sbx-net", "docker network create sbx-net", "blocking" },
  { "network inspect sbx-net", "docker network inspect sbx-net", "blocking", "sandbox.nvim://inspect/network-sbx-net" },
  { "network connect sbx-net sbx-web", "docker network connect sbx-net sbx-web", "blocking" },
  { "network disconnect sbx-net sbx-web", "docker network disconnect sbx-net sbx-web", "blocking" },
  { "network remove sbx-net", "docker network rm sbx-net", "job" },
  { "network prune", "docker network prune -f", "async" },
  { "registry logout", "docker logout", "blocking" },
  { "registry logout ghcr.io", "docker logout ghcr.io", "blocking" },
}

local steps = {
  { lua = [[dofile(vim.fn.getcwd() .. "/TESTS/sheets/_helpers.lua")]] },
  { keys = ":Sandbox engine set docker<CR>" },

  { lua = "_G.fresh(); _G.before = _G.toasts()" },
  { keys = ":Sandbox image pull alpine<CR>", note = "section 2: no --buffer" },
  { wait = [[_G.only_call("docker pull alpine", "async") and _G.noted("Image pulled successfully: alpine")]] },
  { lua = "vim.wait(200)" },
  {
    expect = [[_G.toasts() == _G.before + 2 and _G.noted("Pulling image alpine...") and vim.bo.buftype == ""
      and vim.fn.winnr("$") == 1]],
    note = "one start and one completion toast, no buffer, no window",
  },
  {
    expect = [[_G.on_screen("[sandbox.nvim] Image pulled successfully: alpine")]],
    note = "the toast on screen carries the plugin's prefix",
  },

  { lua = "_G.fresh()" },
  { keys = ":Sandbox image remove alpine:edge<CR>", note = "confirm_destructive on: asks first" },
  { wait = [[_G.float_has("Remove image alpine:edge?")]] },
  { expect = [[#_G.calls == 0]] },
  { keys = "y" },
  { wait = [[_G.only_call("docker rmi alpine:edge", "job")]] },
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
end

local tail = {
  { lua = "_G.fresh()" },
  { wait = [[vim.fn.mode() == "n"]] },
  { keys = ":Sandbox image list<CR>" },
  { wait = [[_G.bufname() == "sandbox.nvim://image-list" and _G.text():find("alpine", 1, true) ~= nil]] },
  { lua = [[vim.cmd("1"); _G.clear()]] },
  { keys = "h", note = "image list: h history" },
  {
    wait = [[_G.saw("docker history alpine:edge") and _G.bufname() == "sandbox.nvim://logs/image-history/alpine:edge"]],
  },
  { lua = [[vim.cmd("wincmd p"); _G.clear()]] },
  { keys = "i", note = "i inspect" },
  { wait = [[_G.saw("docker inspect alpine:edge")]] },
  { lua = [[vim.cmd("wincmd p"); _G.clear()]] },
  { input = "t", note = "t tag prompts for the target (input: keys would end its insert mode)" },
  { wait = [[_G.in_float() and vim.fn.mode() == "i"]] },
  { input = "my/alpine:2<CR>" },
  { wait = [[_G.saw("docker tag alpine:edge my/alpine:2")]] },
  { lua = [[vim.cmd("stopinsert")]] },
  { wait = [[vim.fn.mode() == "n" and _G.bufname() == "sandbox.nvim://image-list"]] },
  { lua = "_G.clear()" },
  { keys = "D", note = "D remove" },
  { wait = [[_G.saw("docker rmi alpine:edge")]] },
  { keys = "R", note = "R refresh" },
  { wait = [[_G.saw("docker images --format {{json .}}")]] },

  { lua = "_G.fresh()" },
  { keys = ":Sandbox volume list<CR>" },
  { wait = [[_G.bufname() == "sandbox.nvim://volume-list" and _G.text():find("sbx-volume", 1, true) ~= nil]] },
  { lua = [[vim.fn.search("sbx-volume"); _G.clear()]] },
  { keys = "i", note = "volume list: i inspect, folded" },
  { wait = [[_G.saw("docker volume inspect sbx-volume") and vim.wo.foldmethod == "indent"]] },
  { keys = "q" },
  { wait = [[_G.bufname() == "sandbox.nvim://volume-list"]], note = "q closes the inspect view" },
  { lua = "_G.clear()" },
  { keys = "D" },
  { wait = [[_G.saw("docker volume rm sbx-volume")]] },
  { keys = "R" },
  { wait = [[_G.saw("docker volume ls --format {{json .}}")]] },

  { lua = "_G.fresh()" },
  { keys = ":Sandbox network list<CR>" },
  { wait = [[_G.bufname() == "sandbox.nvim://network-list" and _G.text():find("sbx-network", 1, true) ~= nil]] },
  { lua = [[vim.fn.search("sbx-network"); _G.clear()]] },
  { keys = "<CR>", note = "network list: <CR> inspect" },
  { wait = [[_G.saw("docker network inspect sbx-network")]] },
  { keys = "q" },
  { wait = [[_G.bufname() == "sandbox.nvim://network-list"]] },
  { lua = "_G.clear()" },
  { keys = "D" },
  { wait = [[_G.saw("docker network rm sbx-network")]] },
  { keys = "R" },
  { wait = [[_G.saw("docker network ls --format {{json .}}")]] },

  { lua = "_G.fresh()" },
  { input = ":Sandbox registry login<CR>", note = "registry login (input: keys would end its insert mode)" },
  { wait = [[_G.asks("username")]] },
  { input = "sbx-user<CR>" },
  { wait = [[_G.asks("password")]] },
  { input = "s3cret-pw" },
  { lua = "vim.wait(100)" },
  {
    expect = [[_G.on_screen("*********") and not _G.on_screen("s3cret")]],
    note = "the typed password is masked on screen",
  },
  { input = "<CR>" },
  { wait = [[_G.only_call("docker login --username sbx-user --password-stdin", "blocking")]] },
  {
    expect = [[_G.calls[1].input == "s3cret-pw" and not vim.fn.execute("messages"):find("s3cret", 1, true)]],
    note = "the password goes through stdin, never into argv or :messages",
  },
  { wait = [[_G.noted("Logged in to Docker Hub")]] },
  { lua = [[vim.cmd("stopinsert")]] },
  { expect = [[#_G.other_spawns == 0 or error(vim.inspect(_G.other_spawns))]], note = "no real process" },
}
for i = 1, #tail do
  steps[#steps + 1] = tail[i]
end

return {
  id = "sandbox.cmds-resources",
  title = "sandbox.nvim: every :Sandbox image, volume, network and registry command reaches the engine with "
    .. "the argv it names; the list keys",
  task = "sandbox.nvim/manual-checklist-run",
  sizes = { { rows = 40, cols = 160 } },
  steps = steps,
  manual = {
    "against a real engine and registry: build, save/remove/load, prune and push really change what "
      .. "`image list` shows; a real login lets a push through and logout stops it",
  },
}
