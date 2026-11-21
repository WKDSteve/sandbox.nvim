---@module 'sandbox.adapters.wsl.list_distros'
---@brief Lists all registered WSL distributions and their running state.

local run_argv = require("sandbox.util.run_argv")

local M = {}

--- Parses WSL distro list output and returns structured distro info.
--- `wsl --list --verbose` outputs UTF-16 LE on Windows; vim.system decodes it.
---@param on_done? fun(distros: WslDistro[]|nil, err: string|nil) Optional: when given, runs asynchronously
---       (with a progress indicator) and delivers exactly the values the synchronous form returns.
---@return WslDistro[]|nil distros
---@return string|nil err
function M.list_distros(on_done)
  local function finish(ok, output)
    if not ok then
      return nil, output
    end

    -- Strip carriage returns and leading/trailing whitespace introduced by UTF-16 decoding
    output = output:gsub("\r", "")

    local distros = {}

    -- Skip the header line ("  NAME   STATE   VERSION")
    local lines = vim.split(output, "\n", { trimempty = true })
    for i = 2, #lines do
      local line = lines[i]
      -- Leading '*' marks the default distro
      local is_default = line:sub(1, 1) == "*"
      -- Strip the marker and normalize whitespace
      local clean = line:gsub("^%*?%s+", "")
      local name, state = clean:match("^(%S+)%s+(%S+)")
      if name and state then
        distros[#distros + 1] = {
          name = name,
          state = state,
          default = is_default,
        }
      end
    end

    return distros, nil
  end

  return run_argv.captured({ "wsl", "--list", "--verbose" }, finish, on_done, { stdout_only = true })
end

return M
