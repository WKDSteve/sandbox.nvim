-- Live check: the hover.nvim preview of an image reference, section 14 of ALL/manual-test-checklists/sandbox.md
-- (task sandbox.nvim/testblatt-bindings-checkliste). The real hover.nvim (TESTS/minimal_init.lua finds it, the sheet
-- puts it on the runtimepath of its child editor); fake engine CLIs (TESTS/sheets/_helpers.lua): `alpine:edge` is
-- pulled, `nginx:1.27-alpine` is not, one container runs from `alpine:edge`.
return {
  id = "sandbox.hover",
  title = "sandbox.nvim: :Hover show on an image reference says pulled or not pulled; never automatic",
  task = "sandbox.nvim/manual-checklist-run",
  sizes = { { rows = 40, cols = 140 } },
  requires = {
    { lua = "vim.g.sandbox_sheets_hover_nvim ~= nil", reason = "hover.nvim not found by TESTS/minimal_init.lua" },
  },
  steps = {
    {
      lua = [[dofile(vim.fn.getcwd() .. "/TESTS/sheets/_helpers.lua")
        vim.opt.rtp:append(vim.g.sandbox_sheets_hover_nvim)
        require("hover").enable({ trigger = { "cursor" }, delay_ms = 50, persist = false,
          auto_hover = { markdown = true, file = true } })
        vim.g.sandbox_engine = "docker"
        _G.containers[#_G.containers + 1] =
          { ID = "fff666fff666fff6", Names = "sbx-edge", State = "running", Image = "alpine:edge" }
        _G.dir = _G.tempdir()
        vim.cmd.cd(vim.fn.fnameescape(_G.dir))
        _G.write(_G.dir .. "/compose.yml", { "services:", "  web:", "    image: alpine:edge" })
        vim.cmd.edit("Dockerfile")
        vim.api.nvim_buf_set_lines(0, 0, -1, false, {
          "FROM alpine:edge",
          "FROM nginx:1.27-alpine",
          "# see init.lua:42",
        })
        -- the text of the float hover.nvim opened for sandbox.nvim, "" when there is none
        function _G.preview()
          for _, w in ipairs(_G.floats()) do
            local t = _G.text(vim.api.nvim_win_get_buf(w))
            if t:find("pulled", 1, true) then return t end
          end
          return ""
        end
        -- the title of that float: its window title, or its first line when hover.nvim draws none
        function _G.preview_title()
          for _, w in ipairs(_G.floats()) do
            local b = vim.api.nvim_win_get_buf(w)
            if _G.text(b):find("pulled", 1, true) then
              local t = vim.api.nvim_win_get_config(w).title
              if type(t) == "table" then
                t = table.concat(vim.tbl_map(function(c) return type(c) == "table" and c[1] or c end, t))
              end
              return (t and t ~= "") and t or vim.api.nvim_buf_get_lines(b, 0, 1, false)[1]
            end
          end
          return ""
        end]],
      note = "a Dockerfile and a compose.yml in a temp project",
    },
    { lua = [[require("sandbox").setup({ hover = false })]], note = "hover = false: no contribution" },
    { lua = "_G.clear()" },
    { keys = "1G6|" },
    { keys = ":Hover show<CR>" },
    { lua = "vim.wait(400)" },
    { expect = [[_G.preview() == "" and #_G.calls == 0 and vim.v.errmsg == ""]], note = "no float, no engine call" },
    { lua = [[require("sandbox.hover").setup()]], note = "the default: hover = true" },

    { lua = [[vim.cmd("silent! fclose!"); _G.clear()]] },
    { keys = "1G6|", note = "rest on alpine:edge without :Hover show" },
    { lua = "vim.wait(500)" },
    { keys = "itext<Esc>", note = "type around it" },
    { keys = "u" },
    { lua = "vim.wait(300)" },
    { expect = [[_G.preview() == "" and #_G.calls == 0]], note = "never automatic: no float, no process started" },

    { keys = "2G7|", note = "nginx:1.27-alpine, not pulled" },
    { keys = ":Hover show<CR>" },
    { wait = [[_G.preview():find("not pulled", 1, true) ~= nil]] },
    {
      expect = [[_G.has(_G.preview(), ":Sandbox image pull") and not _G.preview():find("container", 1, true)]],
      note = "the hint to pull, nothing else",
    },
    { expect = [[_G.has(_G.preview_title(), "nginx:1.27-alpine")]], note = "titled with the reference" },
    { lua = [[vim.cmd("silent! fclose!")]] },
    { keys = "1G6|", note = "alpine:edge, pulled" },
    { keys = ":Hover show<CR>" },
    { wait = [[_G.preview():find("pulled  ·  7.8MB", 1, true) ~= nil]] },
    {
      expect = [[_G.has(_G.preview(), "id      ·  img0123456789") and _G.has(_G.preview(), "1 container:")
        and _G.has(_G.preview(), "running    sbx-edge")]],
      note = "size, short id and the container created from it, with its state",
    },
    { lua = [[_G.edge = _G.preview(); vim.cmd("silent! fclose!")]] },

    { keys = ":edit compose.yml<CR>" },
    { keys = "3G$", note = "the image: value in compose.yml" },
    { keys = ":Hover show<CR>" },
    { wait = [[_G.preview() == _G.edge]], note = "the same answer as in the Dockerfile" },
    { lua = [[vim.cmd("silent! fclose!")]] },

    { keys = ":buffer Dockerfile<CR>" },
    { keys = "3G13|", note = "init.lua:42, a file reference of the same shape" },
    { keys = ":Hover show<CR>" },
    { lua = "vim.wait(400)" },
    { expect = [[_G.preview() == ""]], note = "never read as an image" },
    { lua = [[vim.cmd("silent! fclose!")]] },

    { lua = [[_G.fail["docker"] = "Cannot connect to the Docker daemon"]], note = "the engine is down" },
    { keys = "1G6|" },
    { keys = ":Hover show<CR>" },
    { lua = "vim.wait(400)" },
    { expect = [[_G.preview() == ""]], note = "no sandbox float, not a wrong 'not pulled'" },
    { lua = [[_G.fail = {}; vim.cmd("silent! fclose!"); vim.cmd.cd(vim.fn.fnameescape(_G.root))]] },
    { expect = [[#_G.other_spawns == 0 or error(vim.inspect(_G.other_spawns))]], note = "no real process" },
  },
  manual = {
    "against a real engine: the id and size of a pulled image match :Sandbox image list",
  },
}
