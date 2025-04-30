{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.local.fragment.vm;

  integrated-keyboard-id = "1:1:AT_Translated_Set_2_keyboard";

  theme = config.local.colorScheme.palette;
in
{
  config = lib.mkIf cfg.enable {
    programs.i3status-rust = {
      enable = true;

      bars.default = {
        theme = "modern";
        icons = "awesome6";
        blocks = [
          {
            block = "custom";
            command = ''
              echo 󰌌 $(swaymsg --raw --type get_inputs \
                | jq --raw-output '
                  .[]
                  | select(.identifier=="${integrated-keyboard-id}")
                  | .libinput.send_events')
            '';
            click = [{
              button = "left";
              cmd = "${lib.getExe' pkgs.sway "swaymsg"} input ${integrated-keyboard-id} events toggle";
              update = true;
            }];
            interval = "once";
          }

          {
            block = "custom";
            command = "echo  $(${lib.getExe' pkgs.mako "makoctl"} mode)";
            click = [{
              button = "left";
              cmd = "${lib.getExe' pkgs.mako "makoctl"} mode -t dnd";
              update = true;
            }];
            interval = "once";
          }

          { block = "music"; }
          {
            block = "memory";
            format = " $icon $mem_used_percents.eng(w:2) ";
          }
          {
            format = " 󰌌 $variant";
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
      };
    };

    wayland.windowManager.sway.config.bars = [{
      statusCommand = "${lib.getExe pkgs.i3status-rust} ${config.home.homeDirectory}/${config.xdg.configFile."i3status-rust/config-default.toml".target}";
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
