{ self
, config
, lib
, llib
, pkgs

, isDarwin
, ...
}:

let
  inherit (self.outputs) homeManagerModules;

  toml-format = pkgs.formats.toml { };
in
{
  imports = [
    homeManagerModules.color-scheme
    { config.local.colorScheme = llib.colorSchemes.oneDark; }
  ];

  config = {
    assertions = [
      { assertion = !isDarwin; message = "this is a HM non-darwin config"; }
    ];

    local.flags.onlyCached = true;

    local.fragment = {
      agenix.enable = true;
      # firefox.enable = true;
      git.enable = true;
      jujutsu.enable = true;
      shell.enable = true;
      # thunderbird.enable = true;
      # tools.enable = true;
      # vm.enable = true;
      zellij.enable = true;
    };

    home.sessionVariables = {
      # TERMINAL = lib.getExe pkgs.kitty;

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

    home.packages = with pkgs; [
      # GUIs
      cura
      element-desktop
      insomnia
      mpv
      pavucontrol

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

    programs.gpg = {
      enable = true;
      homedir = "${config.xdg.dataHome}/gnupg";
    };

    fonts.fontconfig.defaultFonts = {
      monospace = "JetBrainsMono Nerd Font";
    };
  };
}
