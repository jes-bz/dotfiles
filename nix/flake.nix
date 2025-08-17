{
  description = "jesseb nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, config, ... }: {
      
      nixpkgs.config.allowUnfree = true;
      
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ 
          pkgs.atuin
          pkgs.bat
          pkgs.btop
          pkgs.discord
          pkgs.eza
          pkgs.ffmpeg
          pkgs.micro
          pkgs.obsidian
          pkgs.ripgrep
          pkgs.spotify
          pkgs.tmux
          pkgs.tree
          pkgs.uv
          pkgs.vscode
        ];

      homebrew = {
        enable = true;
        brews = [
          "mas"
          "gemini-cli"
        ];
        casks = [
          "arc"
          "batfi"
          "ghostty"
          "iina"
          "karabiner-elements"
          "last-window-quits"
          "logi-options+"
          "logitune"
          "raycast"
          "topnotch"
          "the-unarchiver"
          "transmission"
          "vivaldi"
        ];
        masApps = {
          "NordVPN" = 905953485;
          "Windows App" = 1295203466;
        };
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      fonts.packages = [
        pkgs.nerd-fonts.hack
      ];

      system.defaults = {
        dock.autohide = true;
        dock.persistent-apps = [];
        finder.FXPreferredViewStyle = "clmv";
        loginwindow.GuestEnabled = false;
        NSGlobalDomain.AppleInterfaceStyle = "Dark";
        NSGlobalDomain.KeyRepeat = 2;
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      system.primaryUser = "jesse";

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Jesses-MaxBook-Air
    darwinConfigurations."Jesses-MacBook-Air" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "jesse";
          };
        }
      ];
    };

    # Expose the package set, including overlays, for convienience.
    darwinPackages = self.darwinConfigurations."Jesses-Air".pkgs;
  };
}
