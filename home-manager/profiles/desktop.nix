{ self
, config
, lib
, llib
, pkgs

, isDarwin
, ...
}:

if (isDarwin) then throw "this is a HM non-darwin config" else

let
  inherit (self.outputs) homeManagerModules;
  inherit (self.inputs) agenix;

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

    homeManagerModules.color-scheme
    { config.local.colorScheme = llib.colorSchemes.oneDark; }
  ];

  config = {
    local.fragment = {
      aws.enable = true;
      chromium.enable = true;
      epita.enable = true;
      firefox.enable = true;
      git.enable = true;
      imv.enable = true;
      kitty.enable = true;
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
        DOCKER_CONFIG = "${config.xdg.configHome}/docker";
        HISTFILE = "${config.xdg.dataHome}/bash_history";
        NPM_CONFIG_USERCONFIG = "${config.xdg.dataHome}/npm/npmrc";
        RAD_HOME = "${config.xdg.dataHome}/radicle";
        W3M_DIR = "${config.xdg.configHome}/w3m";
        WAKATIME_HOME = "${config.xdg.configHome}/wakatime";
      };

      packages = with pkgs; [
        # Unfree
        cloudflare-warp
        geogebra6
        spotify
        unityhub
        ## JetBrains
        jetbrains.datagrip
        jetbrains.rider

        # GUIs
        audacity
        blender
        bottles
        calibre
        cura
        element-desktop
        evince
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

    programs.go = {
      enable = true;
      goPath = ".local/share/go";
    };

    programs.gpg = {
      enable = true;
      homedir = "${config.xdg.dataHome}/gnupg";
    };
  };
}
