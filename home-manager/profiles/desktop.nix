{
  config,
  pkgs,

  isDarwin,
  ...
}:

{
  config = {
    assertions = [
      {
        assertion = !isDarwin;
        message = "this is a HM non-darwin config";
      }
    ];

    local.fragment = {
      # Interface
      chromium.enable = true;
      compose-key.enable = true;
      epita.enable = true;
      firefox.enable = true;
      imv.enable = true;
      kanshi.enable = true;
      stylix.enable = true;
      sway.enable = true;
      thunderbird.enable = true;
      waybar.enable = true;
      xdg-mime.enable = true;

      # Tools
      agenix.enable = true;
      aws.enable = true;
      git.enable = true;
      helix.enable = true;
      jujutsu.enable = true;
      kitty.enable = true;
      rust.enable = true;
      shell.enable = true;
      tools.enable = true;
      vscodium.enable = true;
      zed.enable = true;
      zellij.enable = true;
    };

    home = {
      sessionVariables = {
        # Quick access to `~/Development` folder
        dev = "${config.home.homeDirectory}/Development";

        # Would love to get rid of the Desktop folder ☹
        XDG_DESKTOP_DIR = "$HOME";

        # Makes electron apps use ozone and not crash because xwayland is not there
        NIXOS_OZONE_WL = "1";

        # Respect XDG spec
        BUN_INSTALL = "${config.xdg.dataHome}/bun";
        CALCHISTFILE = "${config.xdg.cacheHome}/calc_history";
        DOCKER_CONFIG = "${config.xdg.configHome}/docker";
        HISTFILE = "${config.xdg.dataHome}/bash_history";
        NPM_CONFIG_USERCONFIG = "${config.xdg.dataHome}/npm/npmrc";
        RAD_HOME = "${config.xdg.dataHome}/radicle";
        W3M_DIR = "${config.xdg.configHome}/w3m";
        WAKATIME_HOME = "${config.xdg.configHome}/wakatime";
      };

      packages = with pkgs; [
        # Unfree
        aseprite
        # ida-free
        jetbrains-toolbox
        spotify

        # GUIs
        audacity
        baobab
        blender
        bottles
        calibre
        cura-appimage
        element-desktop
        evince
        figma-linux
        file-roller
        gnome-disk-utility
        insomnia
        upkgs.jellyfin-desktop
        kicad
        legcord
        libreoffice-qt
        localsend
        mpv
        nautilus
        nicotine-plus
        pavucontrol
        prismlauncher
        rawtherapee
        simple-scan
        transmission_4-gtk
        wdisplays
        wireshark
        zulip

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

    # Make NPM respect XDG spec
    xdg.configFile."npm/npmrc".text = ''
      prefix=${config.xdg.dataHome}/npm
      cache=${config.xdg.cacheHome}/npm
      init-module=${config.xdg.configHome}/npm/config/npm-init.js
      logs-dir=${config.xdg.stateHome}/npm/logs
    '';

    programs.broot.enable = true;

    stylix.targets.qt.enable = false;
    stylix.targets.gtk.enable = false;

    programs.go = {
      enable = true;
      env.GOPATH = "${config.home.homeDirectory}/.local/share/go";
    };

    programs.gpg = {
      enable = true;
      homedir = "${config.xdg.dataHome}/gnupg";
    };

    programs.nix-index = {
      enable = true;
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableZshIntegration = false;
    };

    programs.ssh.enableDefaultConfig = false;

    services.tailscale-systray.enable = true;
  };
}
