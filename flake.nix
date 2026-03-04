{
  description = "Multi-agent orchestration system for Claude Code with persistent work tracking";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          dolt = pkgs.buildGoModule {
            pname = "dolt";
            version = "1.83.1";
            src = ./.;
            vendorHash = "sha256-JyLQkQs2/Ld7S4z0Xp8G4R7lJZgJREBtpYcjcHKeio8=";

            /*
            ldflags = [
              "-X github.com/steveyegge/gastown/internal/cmd.Version=${version}"
              "-X github.com/steveyegge/gastown/internal/cmd.Build=nix"
              "-X github.com/steveyegge/gastown/internal/cmd.BuiltProperly=1"
            ];
            */

            modRoot = "./go";
            subPackages = [ "cmd/dolt" ];

            buildInputs = with pkgs; [ icu ];

            meta = with pkgs.lib; {
              description = "Relational database with version control and CLI a-la Git";
              homepage = "https://github.com/dolthub/dolt";
              license = licenses.asl20;
              mainProgram = "dolt";
            };
          };
          default = self.packages.${system}.dolt;
        };

        apps = {
          dolt = flake-utils.lib.mkApp {
            drv = self.packages.${system}.dolt;
          };
          default = self.apps.${system}.dolt;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            go
            gopls
            gotools
            go-tools

            icu
          ];
        };
      }
    );
}
