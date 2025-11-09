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
          pkgs.eza
          pkgs.fd
          pkgs.ffmpeg
          pkgs.fzf
          pkgs.gh
          pkgs.imagemagick
          pkgs.micro
          pkgs.obsidian
          pkgs.ripgrep
          pkgs.tmux
          pkgs.tree
          pkgs.uv
        ];

      homebrew = {
        enable = true;
        brews = [
          "mas"
          "gemini-cli"
          "qwen-code"
        ];
        casks = [
          "alt-tab"
          "arc"
          "batfi"
          "discord"
          "google-drive"
          "iina"
          "karabiner-elements"
          "last-window-quits"
          "logi-options+"
          "logitune"
          "raycast"
          "spotify"
          "topnotch"
          "the-unarchiver"
          "transmission"
          "utm"
          "vivaldi"
          "visual-studio-code"
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
        loginwindow.GuestEnabled = false;
      };

      system.defaults.NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        AppleShowAllExtensions = true;
        KeyRepeat = 2;
        NSAutomaticCapitalizationEnabled = true;
        NSAutomaticPeriodSubstitutionEnabled = true;
        NSTableViewDefaultSizeMode = 1;
        "com.apple.springing.delay" = 0.5;
        "com.apple.springing.enabled" = true;
        "com.apple.trackpad.forceClick" = true;
        "com.apple.trackpad.scaling" = 1.0;
      };

      system.defaults.CustomUserPreferences = {
        "com.apple.systempreferences" = {
          allowCloudDesktopAndDocuments = false;
        };
      };

      system.defaults.finder = {
        FXPreferredViewStyle = "clmv";
        ShowPathbar = true;
        ShowStatusBar = true;
        ShowExternalHardDrivesOnDesktop = true;
        ShowHardDrivesOnDesktop = true;
        ShowRemovableMediaOnDesktop = true;
        FXRemoveOldTrashItems = true;
        _FXSortFoldersFirst = true;
      };

      system.defaults.dock = {
        autohide = true;
        persistent-apps = [];
        mineffect = "scale";
        tilesize = 25;
        show-recents = false;
        showAppExposeGestureEnabled = false;
        showMissionControlGestureEnabled = true;
        wvous-br-corner = 1;  # hot corner - 1 = disabled
      };

      system.defaults.menuExtraClock = {
        ShowAMPM = true;
        ShowDate = 0;
        ShowDayOfWeek = true;
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
