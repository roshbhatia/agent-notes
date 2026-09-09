# agent-notes

Keep review notes beside the files they describe. The `note` CLI stores notes, answers, and line anchors.
The Neovim plugin shows notes in buffers and quickfix lists.

The storage path and version 1 records remain compatible with existing notes. No migration is needed.

## Install

```sh
nix profile add github:roshbhatia/agent-notes
brew install roshbhatia/tap/agent-notes
```

## Neovim

Install the CLI, then choose one plugin manager.

### vim.pack

```lua
vim.pack.add({ { src = "https://github.com/roshbhatia/agent-notes" } })
require("agent_notes").setup({ command = "note" })
```

### Lazy

```lua
{ "roshbhatia/agent-notes", submodules = false,
  opts = { command = "note" }, main = "agent_notes",
}
```

### Nixvim

```nix
{ inputs, pkgs, ... }: {
  programs.nixvim.extraPlugins = [
    inputs.agent-notes.packages.${pkgs.stdenv.hostPlatform.system}.neovim-plugin
  ];
  programs.nixvim.extraConfigLua = ''require("agent_notes").setup({ command = "note" })'';
  home.packages = [ inputs.agent-notes.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
```

Call `require("agent_notes").refresh()` to load notes. Call `require("agent_notes.list").quickfix()` to browse them.
Glyph lookup, picker integration, and review refresh callbacks are optional.
