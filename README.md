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

Choose one installation method. The Lua plugin requires Neovim 0.10 or later and the `note` CLI.
The vim.pack example requires Neovim 0.12 or later.

### vim.pack

Install the CLI with Nix, then add this to `init.lua`.

```lua
vim.pack.add({ { src = "https://github.com/roshbhatia/agent-notes" } })
require("agent_notes").setup({ command = "note" })
```

### Lazy

Install the CLI with Nix, then add this specification to your Lazy plugin list.

```lua
{
  "roshbhatia/agent-notes",
  main = "agent_notes",
  opts = { command = "note" },
}
```

### Nixvim

Add the flake input:

```nix
inputs.agent-notes.url = "github:roshbhatia/agent-notes";
inputs.agent-notes.inputs.nixpkgs.follows = "nixpkgs";
```

In your Nixvim module, pass `inputs` through your module arguments and configure both packages:

```nix
{ inputs, pkgs, ... }: {
  programs.nixvim.extraPlugins = [
    inputs.agent-notes.packages.${pkgs.stdenv.hostPlatform.system}.neovim-plugin
  ];
  programs.nixvim.extraConfigLua = ''require("agent_notes").setup({ command = "note" })'';
  programs.nixvim.extraPackages = [
    inputs.agent-notes.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
```

Call `require("agent_notes").refresh()` to load notes. Call `require("agent_notes.list").quickfix()` to browse them.
Glyph lookup, picker integration, and review refresh callbacks are optional.

Installation references: [vim.pack](https://neovim.io/doc/user/pack/),
[Lazy plugin specifications](https://lazy.folke.io/spec), and
[Nixvim plugin options](https://nix-community.github.io/nixvim/NeovimOptions/index.html).
