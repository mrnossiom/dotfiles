{ config
, lib
, pkgs
, ...
}:

with lib;

let
  theme = config.colorScheme.palette;
in
{
  options = { };

  config = {
    programs.i3status-rust = {
      enable = true;
      bars.default = {
        theme = "modern";
        icons = "awesome6";
        blocks = [
          {
            block = "custom";
            command = "echo  $(${getExe' pkgs.mako "makoctl"} mode)";
            click = [
              {
                button = "left";
                cmd = "${getExe' pkgs.mako "makoctl"} mode -t dnd";
                update = true;
              }
            ];
            interval = "once";
          }

          { block = "music"; }
          {
            block = "memory";
            format = " $icon $mem_used_percents.eng(w:2) ";
          }
          {
            block = "cpu";
            interval = 5;
          }
          {
            format = " 󰌌 $layout ";
            block = "keyboard_layout";
            driver = "sway";
          }
          { block = "backlight"; device = "intel_backlight"; }
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
  };
}
