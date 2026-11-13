---@module 'sandbox.logger'
--- Structured diagnostics logger on lib.nvim's logger (in-memory ring + JSONL
--- file sink, inspectable via :LibLogger show; lib.nvim is a hard dependency).
---
--- notify_level is "off": this module never surfaces messages to the user by
--- itself. sandbox.notify owns all user-facing text; this one only records
--- the full diagnostic context (raw CLI output, exit codes, ...) so it can be
--- inspected later without cluttering the notify popup.

local M = require("lib.nvim.logger").new({
  name = "sandbox.nvim",
  notify_level = "off",
})

return M
