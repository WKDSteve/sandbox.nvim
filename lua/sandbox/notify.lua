---@module 'sandbox.notify'
--- Notify wrapper on lib.nvim's notify factory (lib.nvim is a hard dependency).
---
--- warn/error additionally forward to sandbox.logger for structured
--- diagnostics (raw CLI output, exit codes, ...) via an optional `ctx` table,
--- without showing that context to the user - the logger's own notify sink is
--- off, so this never double-notifies.

local logger = require("sandbox.logger")

local base = require("lib.nvim.notify").create("[sandbox.nvim]", { popup = true, source = "sandbox" })

local M = {}

--- @param msg string
function M.info(msg)
  base.info(msg)
end

--- @param msg string
--- @param ctx? table diagnostic context recorded via sandbox.logger, not shown to the user
function M.warn(msg, ctx)
  base.warn(msg)
  logger.warn(msg, ctx)
end

--- @param msg string
--- @param ctx? table diagnostic context recorded via sandbox.logger, not shown to the user
function M.error(msg, ctx)
  base.error(msg)
  logger.error(msg, ctx)
end

return M
