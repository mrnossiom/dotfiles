{ self
, lib
, llib
, config
, pkgs
, isDarwin
  # Provides the NixOS configuration if HM was loaded through the NixOS module
, osConfig ? null
, ...
}:

if (isDarwin) then throw "this is a HM non-darwin config" else

let
  inherit (self.inputs) nix-colors;

  toml-format = pkgs.formats.toml { };
in
{
  imports = [
    # Nix colors
    nix-colors.homeManagerModules.default
    { config.colorScheme = llib.colorSchemes.oneDark; }
  ];

  config = {
    local.flags.onlyCached = true;

    # local.fragment.firefox.enable = true;
    local.fragment.git.enable = true;
    local.fragment.shell.enable = true;
    # local.fragment.thunderbird.enable = true;
    # local.fragment.tools.enable = true;
    # local.fragment.vm.enable = true;

    programs.home-manager.enable = osConfig == null;

    home = {
      stateVersion =
        if osConfig != null
        then osConfig.system.stateVersion
        else "23.11";

      sessionVariables = {
        TERMINAL = lib.getExe pkgs.kitty;

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
        spotify
        ## JetBrains
        jetbrains.datagrip

        # GUIs
        audacity
        cura
        element-desktop
        gnome.file-roller
        gnome.gnome-disk-utility
        gnome.nautilus
        gnome.simple-scan
        insomnia
        mpv
        pavucontrol
        vesktop

        # Needed for libreoffice spellchecking
        hunspell
        hunspellDicts.fr-moderne
        hunspellDicts.en_US-large
        hunspellDicts.en_GB-large

        # CLIs
        wf-recorder
        wl-clipboard
        xdg-utils
      ];
    };

    xdg.configFile."tealdeer/config.toml".source = toml-format.generate "tealdeer-config" {
      updates.auto_update = true;
    };

    # programs.broot.enable = true;

    programs.bat = {
      enable = true;
      config = {
        style = "plain";
      };
    };

    programs.go = {
      enable = true;
      goPath = ".local/share/go";
    };

    home.sessionPath = [ "${config.home.sessionVariables.CARGO_HOME}/bin" ];
    home.file."${config.home.sessionVariables.CARGO_HOME}/config.toml".source = toml-format.generate "cargo-config" {
      build.rustc-wrapper = lib.getExe' pkgs.sccache "sccache";

      # registry.global-credential-providers = [ "cargo:token-from-stdout ${pkgs.writeShellScript "get-crates-io-token" "cat ${config.age.secrets.api-crates-io.path}"}" ];

      source = {
        local-mirror.registry = "sparse+http://local.crates.io:8080/index/";
        # crates-io.replace-with = "local-mirror";
      };

      target = {
        x86_64-unknown-linux-gnu = {
          linker = lib.getExe pkgs.llvmPackages.clang;
          rustflags = [ "-Clink-arg=--ld-path=${lib.getExe pkgs.mold}" "-Ctarget-cpu=native" ];
        };
        x86_64-apple-darwin.rustflags = [ "-Clink-arg=-fuse-ld=${lib.getExe' pkgs.llvmPackages.lld "lld"}" "-Ctarget-cpu=native" ];
        aarch64-apple-darwin.rustflags = [ "-Clink-arg=-fuse-ld=${lib.getExe' pkgs.llvmPackages.lld "lld"}" "-Ctarget-cpu=native" ];
      };

      unstable.gc = true;
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

    fonts.fontconfig.defaultFonts = {
      monospace = "JetBrainsMono Nerd Font";
    };
  };
}
