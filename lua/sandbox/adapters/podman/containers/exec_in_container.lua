---@module 'sandbox.adapters.podman.containers.exec_in_container'
--- Podman Adapter: Execute a command inside a running container

local M = {}

--- Execute a command inside a container
--- Opens a vertical split window with a terminal session inside the specified container.
---
--- @param container_id string: ID or name of the container
--- @param command string[]|nil: Optional command to execute inside the container (default is { "sh" })
--- @param workdir string?: Working directory inside the container (`-w`)
--- @param opts? { interactive?: boolean } `interactive = false` drops `-it` (exec-once)
function M.exec_in_container(container_id, command, workdir, opts)
  command = command or { "sh" }

  -- `-w` when a working directory was asked for. All three engines spell it
  -- the same, and it has to sit before the container id -- after it, the
  -- flag would be handed to the command running *inside* the container.
  -- `-it` for a session; `exec-once` passes `interactive = false`: one command whose output is shown, no stdin, no
  -- tty to answer.
  local args = { "podman", "exec" }
  if not (opts and opts.interactive == false) then
    args[#args + 1] = "-it"
  end
  if type(workdir) == "string" and workdir ~= "" then
    args[#args + 1] = "-w"
    args[#args + 1] = workdir
  end
  args[#args + 1] = container_id
  vim.list_extend(args, command)

  -- `exec_target = "terminal"`: the session is a terminal.nvim terminal instead of a split.
  if require("sandbox.util.exec_target").open(args, container_id) then
    return
  end

  vim.cmd("vnew")

  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_name(buf, require("sandbox.util.exec_target").buffer_name(container_id))

  -- `jobstart({ term = true })` replaces the deprecated `termopen`, but only
  -- exists from 0.11; older supported versions fall back to the old call.
  if vim.fn.has("nvim-0.11") == 1 then
    vim.fn.jobstart(args, { term = true })
  else
    ---@diagnostic disable-next-line: deprecated
    vim.fn.termopen(args)
  end

  vim.bo[buf].bufhidden = "wipe"

  -- Explicitly set the current buffer and enter terminal insert mode
  vim.api.nvim_set_current_buf(buf)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("i", true, false, true), "n", true)
end

return M
