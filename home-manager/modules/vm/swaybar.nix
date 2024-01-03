{ config
, lib
, pkgs
, ...
}:

with lib;

let
  theme = config.colorScheme.colors;
in
{
  options = { };

  config = {
    programs.i3status-rust = {
      enable = true;
      bars.default = rec {
        theme = "modern";
        icons = "awesome6";
        blocks = [
          { block = "focused_window"; }
          {
            block = "disk_space";
            path = "/";
            info_type = "available";
            interval = 60;
            warning = 20.0;
            alert = 10.0;
          }
          { block = "memory"; }
          {
            block = "cpu";
            interval = 5;
          }
          { block = "tea_timer"; }
          {
            block = "pomodoro";
            notify_cmd = "notify-send -w '{msg}'";
            blocking_cmd = true;
          }
          { block = "music"; }
          {
            format = " 󰌌 $layout ";
            block = "keyboard_layout";
            driver = "sway";
          }
          { block = "sound"; }
          { block = "battery"; }
          {
            block = "time";
            interval = 60;
            format = " $timestamp.datetime(f:'%a %d/%m %R') ";
          }
        ];

        # settings.theme = {
        #   inherit theme;
        #   overrides = { };
        # };
      };
    };

    wayland.windowManager.sway.config.bars = [{
      statusCommand = "${getExe pkgs.i3status-rust} ${config.home.homeDirectory}/${config.xdg.configFile."i3status-rust/config-default.toml".target}";
      hiddenState = "hide";
      mode = "hide";
      fonts.size = 11.0;

      colors = {
        background = "#${theme.base00}";
        focusedBackground = "#${theme.base00}";
        separator = "#cccccc";
        focusedSeparator = "#cccccc";
        statusline = "#cccccc";
        focusedStatusline = "#cccccc";

        focusedWorkspace = rec {
          text = "#${theme.base07}";
          background = "#${theme.base0C}";
          border = background;
        };

        inactiveWorkspace = rec {
          text = "#${theme.base05}";
          background = "#${theme.base01}";
          border = background;
        };

        activeWorkspace = rec {
          text = "#${theme.base08}";
          background = "#${theme.base0C}";
          border = background;
        };

        urgentWorkspace = rec {
          text = "#ffffff";
          background = "#${theme.base0F}";
          border = background;
        };

        bindingMode = rec {
          text = "#ffffff";
          background = "#${theme.base0F}";
          border = background;
        };
      };

      # Would be nice to have rounded corners and padding when appearing

      extraConfig = "icon_theme Papirus";
    }];


    # We could've used `(pkgs.formats.toml { }).generate "config.toml" { <opts> }`
    # but this doesn't keep ordering, and ordering is important here
    xdg.configFile."workstyle/config.toml".source = ../../assets/workstyle.toml;
  };
}
