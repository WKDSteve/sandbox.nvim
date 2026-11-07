# Registry

Authentication against a container registry, needed before `image push`/
`image pull` against anything private, under `:Sandbox registry
<subcommand>` (alias `:Sbx registry ...`).

## Login/logout with stdin-piped password

`login` prompts for a username and password (`ui.kit` inputs, the password
one with `secret = true`, masked); the password is piped to the engine CLI via
stdin (`--password-stdin`), never passed as an argv element, so it never
shows up in the process list or shell history. Without a `registry` argument
each engine uses its own default and the message names it: Docker Hub for
docker and nerdctl; for podman the registries.conf default (docker.io unless
configured otherwise). `logout` reverses it.
- **Module:** `sandbox/core/usecases/registry/{login,logout}.lua`
- **Usercmds:** `:Sandbox registry login [registry]`, `:Sandbox registry
  logout [registry]`
