{ self, ... }:
{
  flake.modules.homeManager.profile-desktop =
    {
      config,
      pkgs,
      ...
    }:
    {
      imports = [
        # Interface
        self.modules.homeManager.chromium
        self.modules.homeManager.compose-key
        self.modules.homeManager.epita
        self.modules.homeManager.firefox
        self.modules.homeManager.imv
        self.modules.homeManager.kanshi
        self.modules.homeManager.stylix
        self.modules.homeManager.sway
        self.modules.homeManager.thunderbird
        self.modules.homeManager.waybar
        self.modules.homeManager.xdg-mime

        # Tools
        self.modules.homeManager.agenix
        self.modules.homeManager.git
        self.modules.homeManager.helix
        self.modules.homeManager.jujutsu
        self.modules.homeManager.kitty
        self.modules.homeManager.rust
        self.modules.homeManager.shell
        self.modules.homeManager.tools
        self.modules.homeManager.vscodium
        self.modules.homeManager.zed
        self.modules.homeManager.zellij
      ];
      config = {
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

            # GUIs
            audacity
            baobab
            blender
            (bottles.override { removeWarningPopup = true; })
            calibre
            cura-appimage
            darktable
            element-desktop
            evince
            figma-linux
            file-roller
            freecad
            gimp
            gnome-disk-utility
            insomnia
            kdePackages.kdenlive
            kicad
            libreoffice-qt
            localsend
            mpv
            nautilus
            nicotine-plus
            openscad
            pavucontrol
            prismlauncher
            rawtherapee
            scribus
            simple-scan
            songrec
            transmission_4-gtk
            wdisplays
            wev
            wireshark
            wl-mirror
            zint-qt

            # Needed for libreoffice spellchecking
            hunspell
            hunspellDicts.fr-moderne
            hunspellDicts.en_US-large
            hunspellDicts.en_GB-large

            # CLIs
            pandoc
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

        home.file.".lldbinit".text = ''
          # Very annoying behaviour
          settings set show-statusline true
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

        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
        };

        services.tailscale-systray.enable = true;
      };
    };
}
