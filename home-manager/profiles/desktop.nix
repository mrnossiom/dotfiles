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
  inherit (self.inputs) agenix nix-colors;
  inherit (self.outputs) overlays;

  tomlFormat = pkgs.formats.toml { };
in
{
  imports = [
    agenix.homeManagerModules.default
    ../../secrets

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
        CARGO_HOME = "${config.xdg.dataHome}/cargo";
        DOCKER_CONFIG = "${config.xdg.configHome}/docker";
        HISTFILE = "${config.xdg.dataHome}/bash_history";
        NPM_CONFIG_USERCONFIG = "${config.xdg.dataHome}/npm/npmrc";
        RAD_HOME = "${config.xdg.dataHome}/radicle";
        RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
        W3M_DIR = "${config.xdg.configHome}/w3m";
        WAKATIME_HOME = "${config.xdg.configHome}/wakatime";
      };

      packages = with pkgs; [
        # Unfree
        authy
        discord
        geogebra6
        spotify
        thorium

        jetbrains.datagrip

        # GUIs
        blender
        bottles
        cinnamon.nemo
        cura
        element-desktop
        gnome.gnome-disk-utility
        imv
        mpv
        transmission-gtk

        # CLI tools
        bat
        btop
        calc
        daemon
        delta
        du-dust
        encfs
        fastfetch
        fd
        fzf
        glow
        gping
        jq
        just
        killall
        mind
        ripgrep
        speedtest-go
        spotify-tui
        tealdeer
        trash-cli
        wf-recorder
        wl-clipboard
        xdg-utils
      ];
    };

    # Make NPM respect XDG spec
    xdg.configFile."npm/npmrc".text = ''
      prefix=${config.xdg.dataHome}/npm
      cache=${config.xdg.cacheHome}/npm
      init-module=${config.xdg.configHome}/npm/config/npm-init.js
      logs-dir=${config.xdg.stateHome}/npm/logs
    '';

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
      };
    };

    # TODO: configure
    services.spotifyd.enable = true;

    programs.gpg = {
      enable = true;
      homedir = "${config.xdg.dataHome}/gnupg";
    };

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
