{ self
, config
, pkgs

, isDarwin
, ...
}:

let
  inherit (self.inputs) stylix;
in
{
  imports = [
    stylix.homeModules.stylix
    {
      stylix.enable = true;
      stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/onedark.yaml";
      stylix.fonts = {
        sansSerif = { package = pkgs.inter; name = "Inter"; };
        serif = { package = pkgs.merriweather; name = "Merriweather"; };
        monospace = { package = pkgs.nerd-fonts.jetbrains-mono; name = "JetBrainsMono Nerd Font"; };
      };
      stylix.cursor = {
        name = "Bibata-Modern-Ice";
        package = pkgs.bibata-cursors;
        size = 10;
      };
    }
  ];

  config = {
    assertions = [
      { assertion = !isDarwin; message = "this is a HM non-darwin config"; }
    ];

    local.fragment = {
      agenix.enable = true;
      aws.enable = true;
      chromium.enable = true;
      epita.enable = true;
      firefox.enable = true;
      foot.enable = true;
      git.enable = true;
      helix.enable = true;
      imv.enable = true;
      jujutsu.enable = true;
      rust.enable = true;
      shell.enable = true;
      thunderbird.enable = true;
      tools.enable = true;
      vm.enable = true;
      vscodium.enable = true;
      xdg-mime.enable = true;
      zellij.enable = true;
    };

    home = {
      sessionVariables = {
        # Quick access to `~/Development` folder
        DEV = "${config.home.homeDirectory}/Development";

        # Would love to get rid of the Desktop folder
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
        ida-free
        jetbrains-toolbox
        spotify

        # Game
        superTuxKart

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
        # TODO: move and embed config in nix
        halloy
        heroic
        insomnia
        kicad
        ldtk
        libreoffice-qt
        localsend
        mpv
        nautilus
        pavucontrol
        prismlauncher
        rawtherapee
        showmethekey
        simple-scan
        sonic-pi
        transmission_4-gtk
        vesktop
        wdisplays
        wireshark

        # Needed for libreoffice spellchecking
        hunspell
        hunspellDicts.fr-moderne
        hunspellDicts.en_US-large
        hunspellDicts.en_GB-large

        # TUIs
        lpkgs.asak

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

    # TODO: move out
    programs.ssh = {
      enable = true;

      matchBlocks."weird-row-server" = {
        hostname = "weird-row.portal.wiro.world";
        # TODO: reduce automated load on ssh port by changing to a random port
        # port = ""
      };
    };

    programs.go = {
      enable = true;
      goPath = ".local/share/go";
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
  };
}
