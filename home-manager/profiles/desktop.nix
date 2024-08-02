{ self
, lib
, llib
, config
, pkgs
, upkgs
  # Provides the NixOS configuration if HM was loaded through the NixOS module
, osConfig ? null
, ...
}:

with lib;

let
  inherit (self.inputs) agenix nix-colors;

  all-secrets = import ../../secrets;

  toml-format = pkgs.formats.toml { };
in
{
  imports = [
    agenix.homeManagerModules.default
    {
      age.secrets = all-secrets.home-manager;
      # This allows us to decrypt user space secrets without having to use a
      # passwordless ssh key as you cannot interact with age in the service.
      age.identityPaths = [ "${config.home.homeDirectory}/.ssh/id_home_manager" ];
    }

    # Nix colors
    nix-colors.homeManagerModules.default
    { config.colorScheme = llib.colorSchemes.oneDark; }
  ] ++ map (modPath: ../modules/${modPath}) [
    "aws.nix"
    "chromium.nix"
    "firefox.nix"
    "git.nix"
    "imv.nix"
    "shell.nix"
    "thunderbird.nix"
    "vm"
    "vscodium.nix"
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
        TERMINAL = getExe pkgs.kitty;

        # Quick access to `~/Development` folder
        DEV = "${config.home.homeDirectory}/Development";

        # Would love to get rid of the Desktop folder
        XDG_DESKTOP_DIR = "$HOME";

        # Makes electron apps use ozone and not crash because xwayland is not there
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
        cloudflare-warp
        geogebra6
        spotify
        ## JetBrains
        jetbrains.datagrip

        # GUIs
        audacity
        blender
        bottles
        calibre
        cura
        element-desktop
        evince
        figma-linux
        gnome.file-roller
        gnome.gnome-disk-utility
        gnome.nautilus
        gnome.simple-scan
        heroic
        insomnia
        libreoffice-qt
        localsend
        lutris
        mpv
        obs-studio
        pavucontrol
        prismlauncher
        rawtherapee
        transmission_4-gtk
        vesktop
        wdisplays

        # Needed for libreoffice spellchecking
        hunspell
        hunspellDicts.fr-moderne
        hunspellDicts.en_US-large
        hunspellDicts.en_GB-large

        # TUIs
        asak
        btop
        glow
        gping
        mc
        otree
        thokr

        # CLIs
        calc
        daemon
        delta
        devenv
        du-dust
        encfs
        fastfetch
        fd
        ffmpeg
        file
        fzf
        jq
        just
        killall
        lsof
        mediainfo
        pv
        ripgrep
        speedtest-go
        upkgs.srgn
        sshfs
        sweep
        tealdeer
        tokei
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

    xdg.configFile."tealdeer/config.toml".source = toml-format.generate "tealdeer-config" {
      updates.auto_update = true;
    };

    programs.broot.enable = true;

    programs.bat = {
      enable = true;
      config = {
        style = "plain";
      };
    };

    # Force override file which is not symlinked for whatever reason and causes errors on rebuilds
    xdg.configFile."mimeapps.list".force = true;

    programs.go = {
      enable = true;
      goPath = ".local/share/go";
    };

    home.sessionPath = [ "${config.home.sessionVariables.CARGO_HOME}/bin" ];
    home.file."${config.home.sessionVariables.CARGO_HOME}/config.toml".source = toml-format.generate "cargo-config" {
      build.rustc-wrapper = getExe' pkgs.sccache "sccache";

      registry.global-credential-providers = [ "cargo:token-from-stdout ${pkgs.writeShellScript "get-crates-io-token" "cat ${config.age.secrets.api-crates-io.path}"}" ];

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
          files = [ "org.gnome.Nautilus.desktop" ];
          browser = [ "firefox.desktop" ];
          images = [ "imv.desktop" ];
        in
        {
          "inode/directory" = files;

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

    programs.kitty = {
      enable = true;
      settings = {
        confirm_os_window_close = 0;
        enable_audio_bell = "no";
      };
    };

    programs.gpg = {
      enable = true;
      homedir = "${config.xdg.dataHome}/gnupg";
    };
  };
}
