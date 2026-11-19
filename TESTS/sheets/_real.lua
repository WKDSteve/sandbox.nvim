-- TESTS/sheets/_real.lua -- the child editor of a sheet whose engine CLIs are real processes. Not a sheet
-- (`testing.sheet` only reads *.sheet.lua); a sheet's first step runs it with `dofile`, the child's cwd is the
-- project root.
--
-- Unlike _helpers.lua nothing of the plugin is replaced: `vim.system`, `jobstart` and the terminal run for real, so
-- `testing perf` sees every start with its caller. The programs they start are the recording stand-ins of the sheet's
-- `fakes` (`docker`, `podman`, `wsl`; testing.nvim docs/SHEETS.md), first on the child's PATH: they print nothing and
-- exit 0, so no container engine is ever reached. A step proves the start by the stand-in's log (`_G.ran`).
--
-- The stand-ins are `.cmd` files on Windows: cmd.exe splits an argument at `=` and `,` and ends the list at an empty
-- one, so `_G.ran` asks for the words of a call in order, not for the exact argv.

vim.opt.shortmess:append("I")
vim.o.swapfile = false
vim.o.hidden = true

---The project root (the child's cwd when the first step runs).
_G.root = vim.fs.normalize(vim.fn.getcwd())

local fakes = require("testing.fake_programs")

---The calls of the stand-ins so far, `{ program, argv, cwd }` in order.
---@param program? string only the calls of this program
---@return { program: string, argv: string[], cwd: string }[]
function _G.calls(program)
  return fakes.read(vim.env.TESTING_FAKES, program)
end

---How many calls the stand-ins have seen so far (a mark for `_G.ran(..., since)`).
---@return integer
function _G.mark()
  return #_G.calls()
end

---Whether `program` was called with `words` (space-separated) as a subsequence of its arguments, after the first
---`since` calls.
---@param program string
---@param words string
---@param since? integer
---@return boolean
function _G.ran(program, words, since)
  words = vim.split(words, " ", { trimempty = true })
  local all = _G.calls()
  for i = (since or 0) + 1, #all do
    local c = all[i]
    if c.program == program then
      local at = 1
      for _, a in ipairs(c.argv) do
        if a == words[at] then
          at = at + 1
        end
      end
      if at > #words then
        return true
      end
    end
  end
  return false
end

---The calls as one line each, for an error message.
---@return string
function _G.seen()
  local out = {}
  for i, c in ipairs(_G.calls()) do
    out[i] = c.program .. " " .. table.concat(c.argv, " ")
  end
  return table.concat(out, "\n")
end

---`_G.ran(...)`, or an error that lists what was called.
---@param program string
---@param words string
---@param since? integer
---@return boolean
function _G.must(program, words, since)
  if _G.ran(program, words, since) then
    return true
  end
  error(("no %s %s; calls:\n%s"):format(program, words, _G.seen()), 0)
end

---Before the next command: normal mode, one window on an empty buffer, earlier terminals ended.
function _G.fresh()
  vim.cmd("stopinsert")
  vim.cmd("enew")
  vim.cmd("silent! only")
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[b].buftype == "terminal" then
      vim.api.nvim_buf_delete(b, { force = true })
    end
  end
end

---Whether a toast of sandbox so far holds `text` (plain), read from the popup history.
---@param text string
---@return boolean
function _G.noted(text)
  for _, entry in ipairs(require("lib.nvim.notify.popup").history("sandbox")) do
    if tostring(entry.message):find(text, 1, true) then
      return true
    end
  end
  return false
end

---The current buffer's name from `sandbox.nvim://` on (Neovim before 0.12 makes a path of it on Windows).
---@return string
function _G.bufname()
  local name = vim.api.nvim_buf_get_name(0):gsub("\\", "/")
  local at = name:find("sandbox.nvim://", 1, true)
  return at and name:sub(at) or name
end

---The lines of the current buffer as one string.
---@return string
function _G.text()
  return table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
end

---The focused float asks for `part`: its title (or its text) holds it, and it waits in insert mode.
---@param part string
---@return boolean
function _G.asks(part)
  if vim.api.nvim_win_get_config(0).relative == "" or vim.fn.mode() ~= "i" then
    return false
  end
  local title = vim.api.nvim_win_get_config(0).title
  if type(title) == "table" then
    local chunks = {}
    for i, c in ipairs(title) do
      chunks[i] = type(c) == "table" and c[1] or tostring(c)
    end
    title = table.concat(chunks)
  end
  return tostring(title or ""):find(part, 1, true) ~= nil or _G.text():find(part, 1, true) ~= nil
end

require("sandbox").setup({ confirm_destructive = false })
