{ self
, lib
, config
, pkgs
  # Provides the NixOS configuration if HM was loaded through the NixOS module
, osConfig ? null
, ...
}:

with lib;

let
  inherit (self.inputs) agenix nix-index-database nix-colors;
  inherit (self.outputs) overlays;

  tomlFormat = pkgs.formats.toml { };
in
{
  imports = [
    agenix.homeManagerModules.default
    ../../secrets

    # Setup `comma`, which allow to easily run command that are not present on the system
    nix-index-database.hmModules.nix-index

    # Nix colors
    nix-colors.homeManagerModules.default
    { colorScheme = nix-colors.colorSchemes.onedark; }

    ../modules/vm
    ../modules/git.nix
    ../modules/shell.nix
  ];

  config = {
    nixpkgs = {
      overlays = [ overlays.all ];
      config.allowUnfreePredicate = import ../../lib/unfree.nix;
    };

    programs.home-manager.enable = osConfig == null;

    home = {
      stateVersion =
        if osConfig != null
        then osConfig.system.stateVersion
        else "23.11";

      username = "milomoisson";
      homeDirectory = "/home/milomoisson";

      sessionVariables = {
        XDG_DESKTOP_DIR = "$HOME";

        NIXOS_OZONE_WL = "1";

        # Respect XDG spec
        BUN_INSTALL = "${config.xdg.dataHome}/bun";
        CALCHISTFILE = "${config.xdg.cacheHome}/calc_history";
        HISTFILE = "${config.xdg.dataHome}/bash_history";
        CARGO_HOME = "${config.xdg.dataHome}/cargo";
        RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
        WAKATIME_HOME = "${config.xdg.configHome}/wakatime";
        W3M_DIR = "${config.xdg.configHome}/w3m";

      };

      # Respect XDG spec
      file.".npmrc".text = ''
        prefix=${config.xdg.dataHome}/npm
        cache=${config.xdg.cacheHome}/npm
        init-module=${config.xdg.configHome}/npm/config/npm-init.js
        logs-dir=${config.xdg.stateHome}/npm/logs
      '';

      packages = with pkgs; [
        authy
        discord
        spotify
        thorium
        geogebra6

        # GUIs
        cinnamon.nemo
        transmission-gtk
        gnome.gnome-disk-utility
        cura
        blender
        element-desktop

        xdg-utils
        spotify-tui

        # CLI tools
        just
        bat
        fd
        delta
        ripgrep
        glow
        fzf
        btop
        tealdeer
        jq
        calc
        mind

        imv
        mpv
        wl-clipboard
        wf-recorder
      ];
    };

    xdg.configFile."tealdeer/config.toml".source = tomlFormat.generate "tealdeer-config" {
      updates.auto_update = true;
    };

    programs.broot.enable = true;

    programs.yazi = {
      enable = true;

      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
    };

    # Force override file which is not symlinked for whatever reason and causes errors on rebuilds
    xdg.configFile."mimeapps.list".force = true;

    programs.go = {
      enable = true;
      goPath = ".local/share/go";
    };

    home.file.".cargo/config.toml".source = tomlFormat.generate "cargo-config" {
      build.rustc-wrapper = getExe' pkgs.sccache "sccache";

      source = {
        local-mirror.registry = "sparse+http://local.crates.io:8080/index/";
        # crates-io.replace-with = "local-mirror";
      };

      target = {
        x86_64-unknown-linux-gnu = {
          linker = getExe pkgs.llvmPackages.clang;
          rustflags = [ "-Clink-arg=--ld-path=${getExe pkgs.mold}" "-Ctarget-cpu=native" ];
        };
        x86_64-apple-darwin.rustflags = [ "-Clink-arg=-fuse-ld=${getExe' pkgs.llvmPackages.lld "lld"}" "-Ctarget-cpu=native" ];
        aarch64-apple-darwin.rustflags = [ "-Clink-arg=-fuse-ld=${getExe' pkgs.llvmPackages.lld "lld"}" "-Ctarget-cpu=native" ];
      };

      unstable.gc = true;
    };

    xdg.mimeApps = {
      enable = true;
      associations.added = {
        "application/pdf" = [ "firefox.desktop" ];
      };
      defaultApplications = {
        "application/pdf" = [ "firefox.desktop" ];
      };
    };

    # Nicely reload system units when changing configs
    systemd.user.startServices = "sd-switch";

    programs.firefox = {
      enable = true;
      package = (pkgs.firefox.override {
        nativeMessagingHosts = with pkgs; [ tridactyl-native ];
      });
      profiles.default = {
        isDefault = true;
        settings = {
          "browser.newtabpage.pinned" = [{ title = "NixOS"; url = "https://nixos.org"; }];
        };
      };
    };
    programs.qutebrowser.enable = true;

    programs.kitty = {
      enable = true;
      settings = {
        confirm_os_window_close = 0;
        enable_audio_bell = "no";

        # foreground = "#${config.colorScheme.colors.base05}";
        # background = "#${config.colorScheme.colors.base00}";
      };
    };

    # TODO: configure
    services.spotifyd.enable = true;

    programs.gpg.enable = true;

    programs.topgrade = {
      enable = true;
      package = pkgs.unstable.topgrade;
      settings = {
        misc = {
          # Don't ask for confirmations
          assume_yes = true;

          # Run `sudo -v` to cache credentials at the start of the run; this avoids a
          # blocking password prompt in the middle of a possibly-unattended run.
          pre_sudo = true;

          skip_notify = true;
          disable = [ "rustup" ];
          no_retry = true;
          cleanup = true;
        };

        # TODO: sepcify via global config 
        git.repos = [ "~/Developement/*/*" "~/.config/dotfiles" ];
      };
    };
  };
}
