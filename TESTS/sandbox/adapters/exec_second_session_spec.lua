-- A second `container exec` (or `exec-once`) on the same container while the first session's buffer is still open.
--
-- Every session buffer was named `sandbox.nvim://exec/<id>`, so the second `nvim_buf_set_name` raised E95: the
-- command reported "Failed to exec in container" and, for docker and nerdctl, left the job it had already started
-- running in an unnamed terminal. A second shell into the same container is an ordinary thing to want; it gets the
-- next free name instead.
--
-- The terminal job is a recorder (the argv is pinned by exec_workdir_spec.lua); the split is real, so the names are
-- the ones Neovim really gave the buffers.

local ui_reset = require("TESTS.sandbox.helpers.ui_reset")

describe("adapters.*.containers.exec_in_container, a second session", function()
  local real_termopen, real_jobstart, real_feedkeys
  local started

  before_each(function()
    started = 0
    real_termopen, real_jobstart, real_feedkeys = vim.fn.termopen, vim.fn.jobstart, vim.api.nvim_feedkeys
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.fn.termopen = function()
      started = started + 1
      return 0
    end
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.fn.jobstart = function()
      started = started + 1
      return 0
    end
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.api.nvim_feedkeys = function() end
  end)

  after_each(function()
    vim.fn.termopen, vim.fn.jobstart, vim.api.nvim_feedkeys = real_termopen, real_jobstart, real_feedkeys
    ui_reset.restore()
  end)

  for _, engine in ipairs({ "docker", "podman", "nerdctl" }) do
    it(engine .. ": opens beside the first one under the next free name", function()
      local M = require("sandbox.adapters." .. engine .. ".containers.exec_in_container")
      M.exec_in_container("web", { "sh" })
      local first = vim.api.nvim_get_current_buf()
      M.exec_in_container("web", { "ls" })
      local second = vim.api.nvim_get_current_buf()
      M.exec_in_container("web", { "sh" })
      local third = vim.api.nvim_get_current_buf()

      assert.are.equal(3, started)
      assert.are.equal("sandbox.nvim://exec/web", vim.api.nvim_buf_get_name(first))
      assert.are.equal("sandbox.nvim://exec/web (2)", vim.api.nvim_buf_get_name(second))
      assert.are.equal("sandbox.nvim://exec/web (3)", vim.api.nvim_buf_get_name(third))
    end)
  end
end)
