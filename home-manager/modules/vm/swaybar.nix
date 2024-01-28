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
  # options.programs.waybar.settings = mkOption {
  #   type = types.either (types.listOf interfaceModule) (types.attrsOf interfaceModule);
  # };

  config = {
    programs.waybar = {
      enable = true;
      bars.default = {
        theme = "modern";
        icons = "awesome6";
        blocks = [
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

      settings.main-bar = {
        layer = "top";
        position = "bottom";
        mode = "hide";

        ipc = true;
        id = "bar-0";

        modules-left = [ "sway/workspaces" "sway/window" ];
        modules-center = [ "sway/language" ];
        modules-right = [ "custom/media" "cpu" "memory" "backlight" "pulseaudio" "clock" "battery" "tray" ];

        pulseaudio = {
          tooltip = false;
          scroll-step = 5;
          format = "{icon} {volume}%";
          format-muted = "{icon} {volume}%";
          on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
          format-icons.default = [ "" "" "" ];
        };

        network = {
          tooltip = false;
          format-wifi = "  {essid}";
          format-ethernet = "";
        };

        backlight = {
          tooltip = false;
          format = " {}%";
          interval = 1;
          on-scroll-up = "light -A 5";
          on-scroll-down = "light -U 5";
        };

        battery = {
          states = { good = 95; warning = 30; critical = 15; };
          format = "{icon}  {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-alt = "{time} {icon}";
          format-icons = [ "" "" "" "" "" ];
        };

        tray = {
          icon-size = 18;
          spacing = 10;
        };

        clock.format = "{:%H:%M}  ";

        cpu = {
          interval = 15;
          format = " {}%";
          max-length = 10;
        };

        memory = {
          interval = 30;
          format = " {}%";
          max-length = 10;
        };

        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
        };

        "custom/media" = {
          interval = 30;
          format = "{icon} {}";
          return-type = "json";
          max-length = 20;
          format-icons = {
            spotify = " ";
            default = " ";
          };
          escape = true;
          exec = "$HOME/.config/system_scripts/mediaplayer.py 2> /dev/null";
          on-click = "playerctl play-pause";
        };
      };

      style = readFile ../../assets/waybar.css;
    };

    wayland.windowManager.sway.config.bars = [{
      command = getExe pkgs.waybar;
      hiddenState = "hide";
      mode = "hide";
      fonts.size = 11.0;

      # extraConfig = "icon_theme Papirus";
    }];
  };
}
