{
  description = "Linux Terminal Environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
      apps = pkgs: with pkgs; [
        # Terminal Tools
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
        thunderbird
      ];
    in {
      devShells = forAllSystems (system: {
        default = nixpkgsFor.${system}.mkShell {
          packages = apps nixpkgsFor.${system};
        };
      });

      packages = forAllSystems (system: {
        default = nixpkgsFor.${system}.buildEnv {
          name = "terminal-apps";
          paths = apps nixpkgsFor.${system};
        };
      });
    };
}
