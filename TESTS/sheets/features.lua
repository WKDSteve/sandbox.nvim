-- TESTS/sheets/features.lua -- the functionalities of sandbox.nvim as its user meets them; `testing sheets report`
-- says which ones have a feature sheet (`feature = "<id>"`) and in which state, and K16 warns about a sheet that names
-- an id not listed here. Data: read with an empty environment like a sheet (testing.nvim docs/SHEETS.md).
-- The list follows docs/FEATURES/ (README.md and its pages) and ALL/manual-test-checklists/sandbox.md.
return {
  {
    id = "sandbox.engine",
    title = "One plugin, three CLIs: the engine is detected, pinned per project in .sandboxrc or switched at runtime",
    surface = { "command:Sandbox engine get", "command:Sandbox engine set", "command:Sandbox engine reset" },
    docs = "docs/FEATURES/ENGINES.md",
  },
  {
    id = "sandbox.container-list",
    title = "The container list shows a row per container with its status color, and the row keys act on that row",
    surface = { "command:Sandbox container list" },
    docs = "docs/FEATURES/CONTAINERS.md",
  },
  {
    id = "sandbox.list-refresh",
    title = "A shown list refreshes on its interval and stops when hidden; a multi-selection is confirmed once",
    docs = "docs/FEATURES/UI.md",
  },
  {
    id = "sandbox.container-commands",
    title = "Start, stop, kill, restart, pause, rename, remove and prune a container through :Sandbox container",
    surface = {
      "command:Sandbox container start",
      "command:Sandbox container stop",
      "command:Sandbox container kill",
      "command:Sandbox container restart",
      "command:Sandbox container pause",
      "command:Sandbox container unpause",
      "command:Sandbox container rename",
      "command:Sandbox container remove",
      "command:Sandbox container prune",
    },
    docs = "docs/FEATURES/CONTAINERS.md",
  },
  {
    id = "sandbox.run-wizard",
    title = "The interactive :Sandbox container run wizard starts a new container",
    surface = { "command:Sandbox container run" },
    docs = "docs/FEATURES/CONTAINERS.md",
  },
  {
    id = "sandbox.exec",
    title = ":Sandbox container exec opens a shell in a container, exec-once runs one command; both take workdir=",
    surface = { "command:Sandbox container exec", "command:Sandbox container exec-once" },
    docs = "docs/FEATURES/CONTAINERS.md",
  },
  {
    id = "sandbox.logs",
    title = "Logs of a container, live-following in a buffer, with --buffer streaming instead of a collapsed notify",
    surface = { "command:Sandbox container logs", "command:Sandbox container logs-follow" },
    docs = "docs/FEATURES/CONTAINERS.md",
  },
  {
    id = "sandbox.inspect",
    title = "Inspect, stats, top and cp of a container open in their own view",
    surface = {
      "command:Sandbox container inspect",
      "command:Sandbox container stats",
      "command:Sandbox container top",
      "command:Sandbox container cp",
    },
    docs = "docs/FEATURES/CONTAINERS.md",
  },
  {
    id = "sandbox.resources",
    title = "Images, volumes, networks and the registry login, managed through :Sandbox image/volume/network/registry",
    surface = {
      "command:Sandbox image list",
      "command:Sandbox volume list",
      "command:Sandbox network list",
      "command:Sandbox registry login",
    },
    docs = "docs/FEATURES/IMAGES.md",
  },
  {
    id = "sandbox.compose",
    title = ":Sandbox compose up/down/restart/ps/logs/services act on the compose file found from the cwd",
    surface = { "command:Sandbox compose up", "command:Sandbox compose down", "command:Sandbox compose ps" },
    docs = "docs/FEATURES/COMPOSE.md",
  },
  {
    id = "sandbox.devcontainer",
    title = ".devcontainer/devcontainer.json is detected; build, attach and lazygit work inside it",
    surface = { "command:Sandbox devcontainer build", "command:Sandbox devcontainer attach" },
    docs = "docs/FEATURES/DEVCONTAINER.md",
  },
  {
    id = "sandbox.wsl",
    title = "On Windows, :Sandbox wsl lists, starts, stops, imports and exports WSL distros",
    surface = { "command:Sandbox wsl list", "command:Sandbox wsl start", "command:Sandbox wsl stop" },
    docs = "docs/FEATURES/WSL.md",
  },
  {
    id = "sandbox.alias",
    title = ":Sbx runs every route :Sandbox runs, with the same arguments",
    docs = "docs/BINDINGS.md",
  },
  {
    id = "sandbox.hover",
    title = "A hover.nvim preview of an image reference: pulled or not, size, its containers; never automatic",
    docs = "docs/FEATURES/HOVER.md",
  },
  {
    id = "sandbox.telescope",
    title = "The telescope extension picks a container and acts on it",
    docs = "docs/FEATURES/UI.md",
  },
  {
    id = "sandbox.statusline",
    title = "The statusline component shows 'engine (running/total)', cached for its TTL",
    docs = "docs/FEATURES/UI.md",
  },
  {
    id = "sandbox.docs-generate",
    title = ":Sandbox docs generate writes the route tables of docs/BINDINGS.md from the registered routes",
    surface = { "command:Sandbox docs generate" },
    docs = "docs/FEATURES/UI.md",
  },
}
