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
      formatter = each (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
