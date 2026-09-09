{
  description = "File review notes and Neovim integration";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      each = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = each (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.buildGoModule {
            pname = "agent-notes";
            version = "0.1.0";
            src = self;
            vendorHash = "sha256-WVLALuVohOAdd1s5eRJBRpCfsrpeVzqHu4dGz2UrTlI=";
            subPackages = [ "cmd/note" ];
            nativeCheckInputs = [ pkgs.git ];
            checkPhase = "go test -race ./...";
            meta.mainProgram = "note";
          };
          neovim-plugin = pkgs.vimUtils.buildVimPlugin {
            pname = "agent-notes.nvim";
            version = "0.1.0";
            src = self;
          };
        }
      );
      checks = each (system: {
        cli = self.packages.${system}.default;
        plugin = self.packages.${system}.neovim-plugin;
        plugin-behavior =
          nixpkgs.legacyPackages.${system}.runCommand "agent-notes-plugin-check"
            {
              nativeBuildInputs = [
                nixpkgs.legacyPackages.${system}.neovim
                self.packages.${system}.default
              ];
            }
            ''
              export HOME="$TMPDIR/home"
              export XDG_STATE_HOME="$HOME/state"
              export AGENT_NOTES_SOURCE=${self}
              mkdir -p "$HOME"
              nvim --headless -u NONE -l ${./checks/plugin.lua}
              touch "$out"
            '';
      });
      devShells = each (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.go
              pkgs.git
              pkgs.nixfmt
              pkgs.stylua
              pkgs.neovim
              pkgs.vhs
              pkgs.ffmpeg
            ];
          };
        }
      );
      formatter = each (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.writeShellApplication {
          name = "format-nix";
          runtimeInputs = [
            pkgs.git
            pkgs.nixfmt
            pkgs.findutils
          ];
          text = ''git ls-files -z -- '*.nix' | xargs -0 -r nixfmt "$@"'';
        }
      );
    };
}
