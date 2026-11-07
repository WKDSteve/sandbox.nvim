-- Live check: the container list's auto refresh (`refresh_interval`) and its Visual-mode batch remove, section 1 of
-- ALL/manual-test-checklists/sandbox.md (task sandbox.nvim/testblatt-bindings-checkliste). Fake engine CLIs
-- (TESTS/sheets/_helpers.lua): nothing is started or removed.
return {
  id = "sandbox.list-batch",
  title = "sandbox.nvim: refresh_interval re-renders while shown and stops when hidden or wiped; one confirmation "
    .. "per batch, naming its items",
  task = "sandbox.nvim/testblatt-bindings-checkliste",
  sizes = { { rows = 40, cols = 140 } },
  steps = {
    { lua = [[dofile(vim.fn.getcwd() .. "/TESTS/sheets/_helpers.lua")]] },
    { keys = ":Sandbox engine set docker<CR>" },
    { keys = [[:lua require("sandbox.config").options.refresh_interval = 150<CR>]] },
    { keys = ":Sandbox container list<CR>" },
    { wait = [[_G.listed("docker") >= 4]], note = "the list re-renders itself" },
    { keys = ":enew<CR>", note = "the list is no longer shown in any window" },
    { lua = [[vim.wait(400); _G.seen = _G.listed("docker")]] },
    { lua = [[vim.wait(600)]] },
    { expect = [[_G.listed("docker") == _G.seen]], note = "hidden: the timer stopped" },
    { keys = ":Sandbox container list<CR>", note = "shown again: armed again" },
    { wait = [[_G.listed("docker") >= _G.seen + 3]] },
    { keys = ":bwipeout<CR>" },
    { lua = [[vim.wait(400); _G.seen = _G.listed("docker")]] },
    { lua = [[vim.wait(600)]] },
    { expect = [[_G.listed("docker") == _G.seen and vim.v.errmsg == ""]], note = "wiped: stopped, no error" },
    { keys = [[:lua require("sandbox.config").options.refresh_interval = nil<CR>]] },

    { keys = ":Sandbox container list<CR>" },
    { wait = [[_G.bufname() == "sandbox.nvim://container-list" and _G.text() ~= ""]] },
    { lua = [[_G.row("sbx-cache"); _G.clear()]] },
    { keys = "Vj", note = "two stopped containers" },
    { keys = "D" },
    { wait = [[_G.float_has("Remove 2 containers?")]], note = "one question for the whole batch" },
    {
      expect = [[_G.float_has("sbx-cache") and _G.float_has("sbx-db")]],
      note = "the question names the items it is about to remove",
    },
    { expect = [[#_G.calls == 0]], note = "nothing removed before the answer" },
    { keys = "y" },
    { lua = [[vim.wait(300)]] },
    { expect = [[_G.saw("docker rm " .. _G.id("sbx-cache")) and _G.saw("docker rm " .. _G.id("sbx-db"))]] },
    { expect = [[#_G.calls == 2]], note = "no second question per container" },

    {
      lua = [[for i = 1, 9 do
        _G.containers[#_G.containers + 1] = { ID = ("eee%013d"):format(i), Names = "sbx-more" .. i, State = "exited" }
      end]],
      note = "13 containers",
    },
    { keys = "R" },
    { wait = [[vim.api.nvim_buf_line_count(0) == 13]] },
    { keys = "ggVGD" },
    { wait = [[_G.float_has("Remove 13 containers?")]] },
    { expect = [[_G.float_has("… and 3 more")]], note = "capped at ten names" },
    { keys = "n" },
    { lua = [[vim.wait(200)]] },
    { expect = [[_G.last("docker rm") == nil or #_G.calls == 3]], note = "no: nothing removed" },
    { expect = [[#_G.other_spawns == 0 or error(vim.inspect(_G.other_spawns))]], note = "no real process" },
  },
  manual = {
    "<RightMouse> on a row of the container list: a context menu with the row's actions (ui.contextmenu; "
      .. "nvzone/menu only changes how it is drawn)",
  },
}
