---@module 'sandbox.adapters.podman.images.list_images'
--- Podman Adapter: List images

local run_argv = require("sandbox.util.run_argv")

local M = {}

--- List all local podman images
--- @param on_done? fun(images: table[]|nil, err: string|nil) Optional: when given, runs asynchronously (with a
---        progress indicator) and delivers exactly the values the synchronous form returns.
--- @return table[]|nil images, string|nil err
function M.list_images(on_done)
  local function finish(ok, output)
    if not ok then
      return nil, output
    end

    local decode_ok, result = pcall(vim.fn.json_decode, output)
    if not decode_ok then
      return nil, "invalid image JSON output"
    end

    return result, nil
  end

  return run_argv.captured({ "podman", "images", "--format", "json" }, finish, on_done, { stdout_only = true })
end

return M
