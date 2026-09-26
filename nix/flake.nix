{
  description = "Linux Terminal Environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; config.allowUnfree = true; });

      # Track various npm packages easily with a local package.json
      globalNpmPackages = { system, pkgs }: pkgs.buildNpmPackage {
        pname = "global-npm-packages";
        version = "1.0.0";
        src = ./npm-packages;
        npmDepsHash = "sha256-eHgITeRlythlwEugbpohxg5n7o9dRUUJSewTe1sWv+0=";
        dontNpmBuild = true;
        postInstall = ''
          mkdir -p $out/bin
          # Symlink all dependency binaries to the output bin directory
          if [ -d "$out/lib/node_modules/global-npm-packages/node_modules/.bin" ]; then
            ln -s $out/lib/node_modules/global-npm-packages/node_modules/.bin/* $out/bin/
          fi
        '';
      };

      apps = pkgs: with pkgs; [
        # Terminal Tools
        age
        bat
        btop
        curl
        delta
        eza
        fd
        ffmpeg
        fzf
        gemini-cli
        gh
        git
        glow
        imagemagick
        jq
        micro
        ripgrep
        tmux
        tree
        uv
        wget
        zoxide
        superfile

        # Desktop Apps
        (callPackage ./chatgpt-desktop.nix { })

        # Containers
        docker
      ];
    in {
      devShells = forAllSystems (system: {
        default = nixpkgsFor.${system}.mkShell {
          packages = (apps nixpkgsFor.${system}) ++ [
            (globalNpmPackages { inherit system; pkgs = nixpkgsFor.${system}; })
          ];
        };
      });

      packages = forAllSystems (system: {
        default = nixpkgsFor.${system}.buildEnv {
          name = "terminal-apps";
          paths = (apps nixpkgsFor.${system}) ++ [
            (globalNpmPackages { inherit system; pkgs = nixpkgsFor.${system}; })
          ];
        };
      });
    };
}
