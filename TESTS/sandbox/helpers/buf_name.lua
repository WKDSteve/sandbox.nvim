--- Test helper: the name of a buffer as the plugin gave it.
---
--- Neovim before 0.12 turns the name `sandbox.nvim://x/y` into a path on Windows
--- (`<cwd>\sandbox.nvim:\x\y`). The name the plugin set is the part from
--- `sandbox.nvim://` on, with the separators unified; any other name is given back as it is.

local M = {}

local SCHEME = "sandbox.nvim://"

--- @param name string A buffer name.
--- @return string
function M.clean(name)
  local unified = name:gsub("\\", "/")
  local at = unified:find(SCHEME, 1, true)
  return at and unified:sub(at) or name
end

--- @param buf integer
--- @return string
function M.of(buf)
  return M.clean(vim.api.nvim_buf_get_name(buf))
end

return M
