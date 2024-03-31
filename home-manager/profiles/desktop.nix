{ self
, lib
, llib
, config
, pkgs
  # Provides the NixOS configuration if HM was loaded through the NixOS module
, osConfig ? null
, ...
}:

with lib;

let
  inherit (self.inputs) agenix nix-colors;

  tomlFormat = pkgs.formats.toml { };
in
{
  imports = [
    agenix.homeManagerModules.default
    ../../secrets

    # Nix colors
    nix-colors.homeManagerModules.default
    { config.colorScheme = llib.colorSchemes.oneDark; }
  ] ++ map (modPath: ../modules/${modPath}) [
    "git.nix"
    "shell.nix"
    "taskwarrior.nix"
    "vm"
  ];

  config = {
    programs.home-manager.enable = osConfig == null;

    home = {
      stateVersion =
        if osConfig != null
        then osConfig.system.stateVersion
        else "23.11";

      username = "milomoisson";
      homeDirectory = "/home/milomoisson";

      sessionVariables = {
        # EDITOR is set in the helix module
        TERMINAL = getExe pkgs.kitty;
        BROWSER = getExe pkgs.firefox;

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

        jetbrains.datagrip

        # GUIs
        audacity
        blender
        bottles
        calibre
        chromium
        cura
        element-desktop
        figma-linux
        gnome.gnome-disk-utility
        gnome.nautilus
        imv
        libreoffice-qt
        lutris
        mpv
        pavucontrol
        transmission-gtk

        # Needed for libreoffice spellchecking
        hunspell
        hunspellDicts.fr-moderne
        hunspellDicts.en_US-large
        hunspellDicts.en_GB-large

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
        ffmpeg
        file
        fzf
        glow
        gping
        jq
        just
        killall
        mc
        mind
        ripgrep
        speedtest-go
        spotify-tui
        srgn
        tealdeer
        thokr
        tokei
        trash-cli
        wdisplays
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

    home.file."${config.home.sessionVariables.CARGO_HOME}/config.toml".source = tomlFormat.generate "cargo-config" {
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

    # TODO: move out
    xdg.mimeApps = {
      enable = true;

      defaultApplications =
        let
          browser = [ "firefox.desktop" ];
          images = [ "imv.desktop" ];
        in
        {
          "application/pdf" = browser;
          "text/html" = browser;
          "x-scheme-handler/http" = browser;
          "x-scheme-handler/https" = browser;
          "x-scheme-handler/about" = browser;
          "x-scheme-handler/unknown" = browser;

          # Associate images to `imv`
          "image/bmp" = images;
          "image/gif" = images;
          "image/jpeg" = images;
          "image/jpg" = images;
          "image/pjpeg" = images;
          "image/png" = images;
          "image/tiff" = images;
          "image/heif" = images;
        };

      associations.added = {
        "application/pdf" = [ "firefox.desktop" ];
        "x-scheme-handler/about" = [ "firefox.desktop" ];
        "x-scheme-handler/unknown" = [ "firefox.desktop" ];

        ## Correct LibreOffice applications
        "application/vnd.oasis.opendocument.text" = [ "writer.desktop" ];
        # Word : `.docx`
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [ "writer.desktop" ];
      };
      associations.removed = { };
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
          "browser.gesture.swipe.left" = "";
          "browser.gesture.swipe.right" = "";
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
  };
}
