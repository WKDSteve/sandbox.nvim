---@module 'sandbox.adapters.cli.images.save_image'
--- CLI Adapter (docker, podman, nerdctl): Function to export an image to a tarball
---
--- One definition for every engine that speaks the docker CLI: `new(bin)` returns the functions for
--- the binary `bin`. The per-engine module of the same name calls it (`sandbox.adapters.<engine>.images.save_image`).

local Shared = {}

--- @param bin string the engine's binary (`docker`, `podman`, `nerdctl`)
--- @return table the functions of this module
function Shared.new(bin)
  local run_argv = require("sandbox.util.run_argv")

  local M = {}

  --- Save (export) an image to a tarball on disk
  --- @param image string: image ID or repository:tag
  --- @param path string: destination tarball path
  --- @return boolean ok, string|nil err
  function M.save_image(image, path)
    local ok, output = run_argv.run_blocking_captured({ bin, "save", "-o", path, image })

    if not ok then
      return false, output
    end

    return true, nil
  end

  return M
end

return Shared
