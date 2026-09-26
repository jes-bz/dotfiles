	{
  description = "jesseb nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catthode-ghostty = {
      url = "github:catthode/ghostty/main";
      flake = false;
    };
    catthode-discord = {
      url = "github:catthode/discord/main";
      flake = false;
    };
    catthode-superfile = {
      url = "github:catthode/superfile/main";
      flake = false;
    };
    catthode-obsidian = {
      url = "github:catthode/obsidian/main";
      flake = false;
    };
    catthode-spicetify = {
      url = "github:catthode/spicetify/main";
      flake = false;
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, spicetify-nix, catthode-ghostty, catthode-discord, catthode-superfile, catthode-obsidian, catthode-spicetify }:
  let
    configuration = { pkgs, config, ... }:
    let
      vivaldiExtensionIds =
        map (extension: extension.id)
          (builtins.fromJSON (builtins.readFile ./vivaldi-extensions.json)).extensions;
      vivaldiExtensionIdShell = pkgs.lib.concatStringsSep " " (map (id: "'${id}'") vivaldiExtensionIds);
      vivaldiProfileSettingsFile = ./vivaldi-profile-settings.json;
    in {

      nixpkgs.config.allowUnfree = true;
      
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
          pkgs.age
          pkgs.bat
          pkgs.btop
          pkgs.eza
          pkgs.fd
          pkgs.ffmpeg
          pkgs.fzf
          pkgs.gh
          pkgs.glow
          pkgs.imagemagick
          pkgs.micro
          pkgs.obsidian
          # Keep Vesktop and its bundled Vencord build pinned to nixpkgs.
          (pkgs.vesktop.override {
            withSystemVencord = true;
          })
          pkgs.spicetify-cli
          pkgs.tmux
          pkgs.tree
          pkgs.uv
          pkgs.zoxide
        ];

      # Build Spotify and apply the Catthode theme declaratively. The
      # spicetify-nix wrapper keeps the app and its patch inputs pinned to the
      # flake lock, while this launch flag prevents Spotify's own updater from
      # replacing the managed build between rebuilds.
      programs.spicetify = {
          enable = true;
          theme = {
            name = "Catthode";
            src = catthode-spicetify + /Catthode;
            injectCss = true;
            injectThemeJs = true;
            replaceColors = true;
          };
          colorScheme = "Catthode";
          spotifyLaunchFlags = "--update-endpoint-override=http://localhost";
        };

      homebrew = {
        enable = true;
        brews = [
          "mas"
          "git-delta"
          "mactop"
          "mole"
          "ripgrep"
          "superfile"
          # Third-party tap: trust only imsg, not every tool in steipete/tap.
          {
            name = "steipete/tap/imsg";
            trusted = true;
          }
        ];
        taps = [
        ];
        casks = [
          "adguard"
          "alt-tab"
          "batfi"
          "betterdisplay"
          "bitwarden"
          "codex"
          "codex-app"
          "ghostty"
          "google-drive"
          "hermes-desktop"
          "iina"
          "karabiner-elements"
          "last-window-quits"
          "logi-options+"
          "logitune"
          "nordvpn"
          "raycast"
          "ticktick"
          "topnotch"
          "the-unarchiver"
          "transmission"
          "utm"
          "vivaldi"
          "visual-studio-code"
          "windows-app"
        ];
        masApps = {};
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      fonts.packages = [
        pkgs.nerd-fonts.hack
        pkgs.nerd-fonts.caskaydia-mono
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

      system.activationScripts.postActivation.text = ''
        install -d -m 0755 -o jesse -g staff /Users/jesse/.config/ghostty/themes
        install -d -m 0755 -o jesse -g staff "/Users/jesse/Library/Application Support/com.mitchellh.ghostty"
        if [ -f "/Users/jesse/Library/Application Support/com.mitchellh.ghostty/config" ]; then
          if grep -q -E '^theme[[:space:]]*=' "/Users/jesse/Library/Application Support/com.mitchellh.ghostty/config"; then
            /usr/bin/sed -i "" -E 's/^theme[[:space:]]*=.*/theme = Catthode/' \
              "/Users/jesse/Library/Application Support/com.mitchellh.ghostty/config"
          else
            printf '\ntheme = Catthode\n' >> "/Users/jesse/Library/Application Support/com.mitchellh.ghostty/config"
          fi
        else
          printf 'theme = Catthode\n' > "/Users/jesse/Library/Application Support/com.mitchellh.ghostty/config"
        fi
        ln -sfn ${catthode-ghostty}/themes/Catthode /Users/jesse/.config/ghostty/themes/Catthode
        ln -sfn ${catthode-ghostty}/config /Users/jesse/.config/ghostty/config
        chown -h jesse:staff \
          /Users/jesse/.config/ghostty/themes/Catthode \
          /Users/jesse/.config/ghostty/config

        # Keep the Catthode Discord theme reproducible with Nix-managed Vesktop.
        discord_data_dir="/Users/jesse/Library/Application Support/vesktop"
        discord_theme_dir="$discord_data_dir/themes"
        discord_settings_dir="$discord_data_dir/settings"
        discord_settings="$discord_settings_dir/settings.json"
        install -d -m 0755 -o jesse -g staff "$discord_data_dir" "$discord_theme_dir" "$discord_settings_dir"
        chown jesse:staff "$discord_data_dir"
        ln -sfn ${catthode-discord}/catthode.theme.css "$discord_theme_dir/catthode.theme.css"
        chown -h jesse:staff "$discord_theme_dir/catthode.theme.css"
        if [ -f "$discord_settings" ]; then
          discord_settings_tmp="$(mktemp)"
          if ${pkgs.jq}/bin/jq '
            .enabledThemes = (((.enabledThemes // []) + ["catthode.theme.css"]) | unique)
            | .autoUpdate = false
            | .autoUpdateNotification = false
          ' "$discord_settings" > "$discord_settings_tmp"; then
            install -m 0644 -o jesse -g staff "$discord_settings_tmp" "$discord_settings"
          fi
          rm -f "$discord_settings_tmp"
        else
          printf '%s\n' '{ "enabledThemes": ["catthode.theme.css"], "autoUpdate": false, "autoUpdateNotification": false }' > "$discord_settings"
          chown jesse:staff "$discord_settings"
        fi

        # Keep the Catthode Superfile theme reproducible with the Homebrew formula.
        # Superfile uses ~/Library/Application Support on macOS rather than ~/.config.
        superfile_data_dir="/Users/jesse/Library/Application Support/superfile"
        superfile_theme_dir="$superfile_data_dir/theme"
        superfile_config="$superfile_data_dir/config.toml"
        install -d -m 0755 -o jesse -g staff "$superfile_data_dir" "$superfile_theme_dir"
        chown jesse:staff "$superfile_data_dir"
        ln -sfn ${catthode-superfile}/catthode.toml "$superfile_theme_dir/catthode.toml"
        chown -h jesse:staff "$superfile_theme_dir/catthode.toml"
        if [ -f "$superfile_config" ]; then
          if grep -q -E '^theme[[:space:]]*=' "$superfile_config"; then
            /usr/bin/sed -i "" -E 's|^theme[[:space:]]*=.*|theme = "catthode"|' "$superfile_config"
          else
            printf '\ntheme = "catthode"\n' >> "$superfile_config"
          fi
        else
          printf 'theme = "catthode"\n' > "$superfile_config"
          chown jesse:staff "$superfile_config"
        fi

        # Keep the Catthode Obsidian theme reproducible in every registered vault.
        # Obsidian stores vault paths in its desktop registry; note contents are
        # never read or changed by this block.
        obsidian_registry="/Users/jesse/Library/Application Support/obsidian/obsidian.json"
        if [ -f "$obsidian_registry" ]; then
          ${pkgs.jq}/bin/jq -r '.vaults[]?.path // empty' "$obsidian_registry" 2>/dev/null | while IFS= read -r obsidian_vault; do
            [ -d "$obsidian_vault" ] || continue
            obsidian_theme_dir="$obsidian_vault/.obsidian/themes/Catthode"
            install -d -m 0755 -o jesse -g staff "$obsidian_theme_dir"
            ln -sfn ${catthode-obsidian}/theme.css "$obsidian_theme_dir/theme.css"
            ln -sfn ${catthode-obsidian}/manifest.json "$obsidian_theme_dir/manifest.json"
            chown -h jesse:staff "$obsidian_theme_dir/theme.css" "$obsidian_theme_dir/manifest.json"

            obsidian_appearance="$obsidian_vault/.obsidian/appearance.json"
            if [ -f "$obsidian_appearance" ]; then
              obsidian_appearance_tmp="$(mktemp)"
              if ${pkgs.jq}/bin/jq '.cssTheme = "Catthode" | .accentColor = "#ff9e3b"' "$obsidian_appearance" > "$obsidian_appearance_tmp"; then
                install -m 0644 -o jesse -g staff "$obsidian_appearance_tmp" "$obsidian_appearance"
              fi
              rm -f "$obsidian_appearance_tmp"
            else
              printf '%s\n' '{ "cssTheme": "Catthode", "accentColor": "#ff9e3b" }' > "$obsidian_appearance"
              chown jesse:staff "$obsidian_appearance"
            fi
          done
        fi

        # Keep the Catthode Vivaldi extension/theme/layout state reproducible.
        # Chromium external extension manifests are user-scoped and make
        # Vivaldi install/update Chrome Web Store extensions on next launch.
        vivaldi_data_dir="/Users/jesse/Library/Application Support/Vivaldi"
        vivaldi_profile_dir="$vivaldi_data_dir/Default"
        vivaldi_external_dir="$vivaldi_data_dir/External Extensions"
        install -d -m 0755 -o jesse -g staff "$vivaldi_external_dir"
        for vivaldi_extension_id in ${vivaldiExtensionIdShell}; do
          vivaldi_extension_tmp="$(mktemp)"
          printf '{ "external_update_url": "https://clients2.google.com/service/update2/crx" }\n' > "$vivaldi_extension_tmp"
          install -m 0644 -o jesse -g staff "$vivaldi_extension_tmp" \
            "$vivaldi_external_dir/$vivaldi_extension_id.json"
          rm -f "$vivaldi_extension_tmp"
        done

        # Preferences contain browsing data alongside UI state. Merge only the
        # versioned UI allowlist so bookmarks, history, cookies, credentials,
        # sync state, and extension storage remain untouched.
        vivaldi_preferences="$vivaldi_profile_dir/Preferences"
        if [ -f "$vivaldi_preferences" ] && [ -f "${vivaldiProfileSettingsFile}" ]; then
          if /usr/bin/pgrep -x Vivaldi >/dev/null 2>&1 || /usr/bin/pgrep -f '/Applications/Vivaldi.app/Contents/MacOS/Vivaldi' >/dev/null 2>&1; then
            echo "Skipping Vivaldi UI preference restore: Vivaldi is running. Quit Vivaldi and run nix-rebuild again."
          else
            vivaldi_preferences_tmp="$(mktemp)"
            if ${pkgs.jq}/bin/jq --slurpfile snapshot "${vivaldiProfileSettingsFile}" '
              ($snapshot[0]) as $s
              | .browser.theme = ((.browser.theme // {}) * ($s.browser.theme // {}))
              | .vivaldi.address_bar = ((.vivaldi.address_bar // {}) * ($s.vivaldi.address_bar // {}))
              | .vivaldi.appearance = ((.vivaldi.appearance // {}) * ($s.vivaldi.appearance // {}))
              | .vivaldi.bookmarks = ((.vivaldi.bookmarks // {}) * ($s.vivaldi.bookmarks // {}))
              | .vivaldi.downloads = ((.vivaldi.downloads // {}) * ($s.vivaldi.downloads // {}))
              | .vivaldi.features = ((.vivaldi.features // {}) * ($s.vivaldi.features // {}))
              | .vivaldi.layouts = ((.vivaldi.layouts // {}) * ($s.vivaldi.layouts // {}))
              | .vivaldi.menu = ((.vivaldi.menu // {}) * ($s.vivaldi.menu // {}))
              | .vivaldi.mouse_gestures = ((.vivaldi.mouse_gestures // {}) * ($s.vivaldi.mouse_gestures // {}))
              | .vivaldi.panels = ((.vivaldi.panels // {}) * ($s.vivaldi.panels // {}))
              | .vivaldi.panels.web = ((.vivaldi.panels.web // {}) * ($s.vivaldi.panels.web // {}))
              | .vivaldi.quick_commands = ((.vivaldi.quick_commands // {}) * ($s.vivaldi.quick_commands // {}))
              | .vivaldi.startpage = ((.vivaldi.startpage // {}) * ($s.vivaldi.startpage // {}))
              | .vivaldi.status_bar = ((.vivaldi.status_bar // {}) * ($s.vivaldi.status_bar // {}))
              | .vivaldi.system = ((.vivaldi.system // {}) * ($s.vivaldi.system // {}))
              | .vivaldi.tabs = ((.vivaldi.tabs // {}) * ($s.vivaldi.tabs // {}))
              | .vivaldi.theme = ((.vivaldi.theme // {}) * ($s.vivaldi.theme // {}))
              | .vivaldi.themes = ((.vivaldi.themes // {}) * ($s.vivaldi.themes // {}))
              | .vivaldi.toolbars = ((.vivaldi.toolbars // {}) * ($s.vivaldi.toolbars // {}))
              | .vivaldi.translate = ((.vivaldi.translate // {}) * ($s.vivaldi.translate // {}))
              | .vivaldi.workspaces = ((.vivaldi.workspaces // {}) * ($s.vivaldi.workspaces // {}))
            ' "$vivaldi_preferences" > "$vivaldi_preferences_tmp"; then
              install -m 0600 -o jesse -g staff "$vivaldi_preferences_tmp" "$vivaldi_preferences"
              echo "Restored Catthode Vivaldi UI preferences."
            else
              echo "Warning: Vivaldi UI preference restore failed; leaving the existing profile unchanged." >&2
            fi
            rm -f "$vivaldi_preferences_tmp"
          fi
        fi

        # Spotify and Catthode are managed declaratively by spicetify-nix.
        # Its generated package owns the Spotify payload and applies the theme;
        # there is no mutable /Applications/Spotify.app activation step here.

        # Homebrew Bundle's VS Code extension detector cannot see the cask's
        # `code` shim during nix-darwin activation because sudo supplies a
        # restricted PATH. Keep the current Homebrew editor, but restore the
        # captured Marketplace set directly through its user-scoped CLI.
        vscode_bin="/opt/homebrew/bin/code"
        if [ -x "$vscode_bin" ]; then
          vscode_installed="$(
            /usr/bin/sudo --user=jesse --set-home /usr/bin/env \
              PATH="/opt/homebrew/bin:/usr/bin:/bin" \
              "$vscode_bin" --list-extensions 2>/dev/null || true
          )"
          while IFS= read -r vscode_extension; do
            [ -n "$vscode_extension" ] || continue
            if ! printf '%s\n' "$vscode_installed" | /usr/bin/grep -Fxiq "$vscode_extension"; then
              if /usr/bin/sudo --user=jesse --set-home /usr/bin/env \
                PATH="/opt/homebrew/bin:/usr/bin:/bin" \
                "$vscode_bin" --install-extension "$vscode_extension" --force >/dev/null 2>&1; then
                echo "Restored VS Code extension: $vscode_extension"
              else
                echo "Warning: VS Code extension restore failed: $vscode_extension" >&2
              fi
            fi
          done <<'EOF'
bbenoist.nix
catthode.catthode
charliermarsh.ruff
dbaeumer.vscode-eslint
donjayamanne.python-environment-manager
github.github-vscode-theme
github.vscode-github-actions
google.gemini-cli-vscode-ide-companion
kilocode.kilo-code
mechatroner.rainbow-csv
meta.pyrefly
ms-python.debugpy
ms-python.isort
ms-python.python
ms-python.vscode-pylance
ms-toolsai.jupyter
ms-toolsai.jupyter-keymap
ms-toolsai.jupyter-renderers
ms-toolsai.vscode-jupyter-cell-tags
ms-toolsai.vscode-jupyter-slideshow
ms-vscode-remote.remote-ssh
ms-vscode-remote.remote-ssh-edit
ms-vscode.remote-explorer
pkief.material-icon-theme
streetsidesoftware.code-spell-checker
tamasfe.even-better-toml
EOF
        else
          echo "Warning: Visual Studio Code CLI not found; skipped extension restore." >&2
        fi
      '';

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
        spicetify-nix.darwinModules.default
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
