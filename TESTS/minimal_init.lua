-- TESTS/minimal_init.lua -- puts this plugin and its dependencies on the runtimepath.
--
--   nvim -n -i NONE --headless -u TESTS/minimal_init.lua ...
--
-- It runs nothing itself. A dependency that cannot be found is FATAL (NEW-40): the message names
-- all four places that were searched and the process exits with code 1, so that a run which could
-- not load its dependency never looks green. Each dependency <name> is looked up in, in this order:
--   1. $<NAME>_DIR                  (lib.nvim -> $LIB_NVIM_DIR)
--   2. <repo>/.deps/<name>          (what CI checks out)
--   3. <repo>/../<name>             (a sibling checkout)
--   4. stdpath('data')/lazy/<name>  (what a plugin manager installed)
-- An override (1) that is set but wrong decides alone; it is never skipped.

local this = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p")
local root = vim.fs.dirname(vim.fs.dirname(vim.fs.normalize(this)))

local DEPS = { "testing.nvim", "lib.nvim", "ui.nvim", "hover.nvim" }

-- Found like the others (`ci commit` hands it over as $HOVER_NVIM_DIR because it is named above), but left off the
-- runtimepath: the specs stub `hover.registry` themselves (TESTS/sandbox/hover_spec.lua). The test sheet of section 14
-- runs the real hover.nvim and adds it in its child editor (TESTS/sheets/sandbox-hover.sheet.lua,
-- vim.g.sandbox_sheets_hover_nvim).
---@type table<string, true>
local SHEETS_ONLY = { ["hover.nvim"] = true }

---@type table<string, string>
local MARKERS = { ["lib.nvim"] = "lua/lib/nvim", ["testing.nvim"] = "lua/testing" }

---@param name string
---@return string
local function env_name(name)
  return (name:upper():gsub("[^%w]", "_")) .. "_DIR"
end

---@param dir string|nil
---@param marker string
---@return boolean
local function valid(dir, marker)
  return dir ~= nil and dir ~= "" and vim.fn.isdirectory(dir .. "/" .. marker) == 1
end

local found, failures = {}, {}
for _, name in ipairs(DEPS) do
  local marker = MARKERS[name] or "lua"
  local override = vim.env[env_name(name)]
  local places = {
    { "$" .. env_name(name), override },
    { (".deps/%s"):format(name), root .. "/.deps/" .. name },
    { ("../%s"):format(name), vim.fs.dirname(root) .. "/" .. name },
    {
      ("stdpath('data')/lazy/%s"):format(name),
      vim.fs.normalize(vim.fn.stdpath("data")) .. "/lazy/" .. name,
    },
  }
  local hit
  if override ~= nil and override ~= "" then
    if valid(override, marker) then
      hit = override
    end
  else
    for i = 2, #places do
      if valid(places[i][2], marker) then
        hit = places[i][2]
        break
      end
    end
  end
  if hit then
    found[name] = hit
  elseif not SHEETS_ONLY[name] then
    local lines = { ("error: dependency '%s' not found. Searched, in this order:"):format(name) }
    for i, p in ipairs(places) do
      lines[#lines + 1] = ("  %d. %s (%s)"):format(i, p[1], p[2] or "unset")
    end
    lines[#lines + 1] = ("Set $%s, or clone it to .deps/%s, or place it beside this repo."):format(env_name(name), name)
    failures[#failures + 1] = table.concat(lines, "\n")
  end
end

if #failures > 0 then
  io.stderr:write(table.concat(failures, "\n"), "\n")
  os.exit(1)
end

vim.opt.rtp:prepend(root)
for _, name in ipairs(DEPS) do
  if not SHEETS_ONLY[name] then
    vim.opt.rtp:append(found[name])
  end
end
vim.g.sandbox_sheets_hover_nvim = found["hover.nvim"]

-- Swap and shada stay off for the whole suite: stale swap files fail suites with E326.
vim.o.swapfile = false
vim.o.shadafile = "NONE"

return { root = root, deps = found }
