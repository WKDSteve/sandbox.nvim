-- Live check: the statusline component (section 12 of ALL/manual-test-checklists/sandbox.md) and
-- `:Sandbox docs generate` (section 13), the generated table checked against the hand-maintained docs/BINDINGS.md.
-- Fake engine CLIs (TESTS/sheets/_helpers.lua). docs generate writes into the cwd, so it runs in a temp directory:
-- the repository's own docs/GENERATED_COMMANDS.md is never touched.
return {
  id = "sandbox.statusline-docs",
  title = "sandbox.nvim: statusline 'engine (running/total)', cached for the TTL; docs generate and BINDINGS.md",
  task = "sandbox.nvim/testblatt-bindings-checkliste",
  sizes = { { rows = 30, cols = 120 } },
  steps = {
    { lua = [[dofile(vim.fn.getcwd() .. "/TESTS/sheets/_helpers.lua")]] },
    { keys = ":Sandbox engine set docker<CR>" },
    { lua = [[_G.status = require("sandbox.statusline").status; _G.status()]], note = "the first call starts a read" },
    { wait = [[_G.status() == "docker (1/4)"]], note = "one of four running (a paused one is not running)" },
    { keys = ":Sandbox container list<CR>" },
    {
      wait = [[vim.api.nvim_buf_line_count(0) == 4 and #vim.tbl_filter(function(l)
        return l:find("^%[running%]") ~= nil
      end, vim.api.nvim_buf_get_lines(0, 0, -1, false)) == 1]],
      note = "the same counts as the container list",
    },
    { lua = [[_G.seen = _G.listed("docker"); _G.containers[2].State = "running"; _G.status(); _G.status()]] },
    {
      expect = [[_G.listed("docker") == _G.seen and _G.status() == "docker (1/4)"]],
      note = "inside the TTL: no second ps, the count does not move although a container started",
    },
    { lua = [[require("sandbox.config").options.status_cache_ttl_ms = 200; vim.wait(300); _G.status()]] },
    { wait = [[_G.status() == "docker (2/4)"]], note = "after the TTL it asks again" },
    { expect = [[_G.listed("docker") == _G.seen + 1]] },
    {
      lua = [[_G.fail["docker ps"] = "Cannot connect to the Docker daemon"; vim.wait(300); _G.status()]],
      note = "the daemon stops answering",
    },
    { lua = [[vim.wait(50)]] },
    {
      expect = [[_G.status() == "docker" and vim.v.errmsg == ""]],
      note = "degrades to the bare engine name (docs/statusline.md), no error, no stale counts",
    },
    { lua = [[_G.fail = {}]] },

    {
      lua = [[_G.out = _G.tempdir(); vim.cmd.cd(vim.fn.fnameescape(_G.out))
        _G.generated = _G.out .. "/docs/GENERATED_COMMANDS.md"]],
      note = "docs generate writes into the cwd",
    },
    { keys = ":Sandbox docs generate<CR>" },
    { wait = [[_G.noted("Generated docs/GENERATED_COMMANDS.md") and vim.fn.filereadable(_G.generated) == 1]] },
    { lua = [[_G.gen = table.concat(vim.fn.readfile(_G.generated), "\n")]] },
    {
      expect = [[_G.has(_G.gen, "| `:Sandbox container list` | List all containers |")
        and _G.has(_G.gen, "| `:Sandbox compose up` |") and _G.has(_G.gen, "| `:Sbx engine reset` |")]],
      note = "the live route table, both command names",
    },
    {
      lua = [[-- every `:Sandbox <ns> <verb>` generated has a `<verb>` row under its namespace in BINDINGS.md
        _G.missing = {}
        local doc, section = {}, nil
        for _, line in ipairs(vim.fn.readfile(_G.root .. "/docs/BINDINGS.md")) do
          section = line:match("^## `:Sandbox (%S+)") or (line:match("^## ") and "") or section
          local verb = section and line:match("^| `([%w%-]+)`")
          if verb then doc[section .. " " .. verb] = true end
        end
        for _, line in ipairs(vim.fn.readfile(_G.generated)) do
          local route = line:match("^| `:Sandbox (%S+ [%w%-]+)")
          if route and not doc[route] then _G.missing[#_G.missing + 1] = route end
        end]],
    },
    { expect = [[#_G.missing == 0 or error("not in docs/BINDINGS.md: " .. table.concat(_G.missing, ", "), 0)]] },
    { lua = [[vim.cmd.cd(vim.fn.fnameescape(_G.root))]] },
    { expect = [[#_G.other_spawns == 0 or error(vim.inspect(_G.other_spawns))]], note = "no real process" },
  },
  manual = {
    "against a real engine: the counts match `docker ps -a`; with the daemon stopped the component shows no counts",
  },
}
