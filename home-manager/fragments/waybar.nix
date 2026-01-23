{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.local.fragment.waybar;

  makoctl = lib.getExe' config.services.mako.package "makoctl";
in
{
  options.local.fragment.waybar.enable = lib.mkEnableOption ''
    Waybar related
  '';

  config = lib.mkIf cfg.enable {
    stylix.targets.waybar = {
      font = "sansSerif";
      addCss = false;
    };

    services.playerctld.enable = true;

    programs.waybar = {
      enable = true;

      settings =
        let
          modules-settings = {
            "sway/workspaces" = {
              disable-scroll = true;
              format = "{name} {icon}";
              format-icons = {
                default = "●";

                "1" = " ";
                "2" = " ";
                "3" = " ";
                "4" = " ";
                "9" = " ";
                "10" = " ";
              };
            };

            "group/misc" = {
              orientation = "inherit";
              modules = [
                "custom/notifications"
                "tray"
                "idle_inhibitor"
              ];

              drawer = {
                transition-duration = 250;
                transition-left-to-right = false;
              };
            };

            "custom/notifications" = {
              format = "{icon}";
              format-icons = {
                normal = " ";
                dnd = " ";
              };
              tooltip = false;

              interval = "once";
              return-type = "json";
              exec = ''${makoctl} mode | rg dnd >/dev/null; if [ $? == 0 ]; then echo '{"alt":"dnd"}'; else echo '{"alt":"normal"}'; fi'';
              on-click = "${makoctl} mode -t dnd; pkill -SIGRTMIN+10 waybar";
              signal = 10;
              # rely on on click pkill signal
              exec-on-event = false;
            };

            idle_inhibitor = {
              format = "{icon}";
              format-icons = {
                activated = " ";
                deactivated = " ";
              };
              tooltip = false;
            };

            tray.spacing = 10;

            clock = {
              format = "{:%d %b %H:%M}";
              tooltip = false;
            };

            battery = {
              states = {
                good = 95;
                warning = 30;
                critical = 15;
              };

              format = "{capacity}% {icon}";
              format-full = "{capacity}% {icon}";
              format-charging = "{capacity}% ";
              format-plugged = "{capacity}% ";
              format-icons = [
                " "
                " "
                " "
                " "
                " "
              ];
            };

            pulseaudio = {
              scroll-step = 5;
              tooltip = false;

              format = "{volume}% {icon}{format_source}";
              format-bluetooth = "{volume}% {icon}{format_source}";
              format-bluetooth-muted = " {icon} {format_source}";
              format-muted = " {format_source}";
              format-source = "";
              format-source-muted = "  ";

              format-icons = {
                headset = " ";
                headphone = " ";
                hands-free = " ";
                phone = " ";
                portable = " ";
                car = " ";
                default = [
                  ""
                  " "
                  "  "
                ];
              };

              on-click = "pavucontrol";
            };

            mpris = {
              format = "{title:.30} - {artist:.30}";
              tooltip-format = "{album} ({player})";
            };

            cava = {
              bars = 6;
              format-icons = [
                "▁"
                "▂"
                "▃"
                "▄"
                "▅"
                "▆"
                "▇"
                "█"
              ];
              bar_delimiter = 0;
              hide_on_silence = true;
            };
          };

        in
        {
          primary = {
            mode = "hide";
            ipc = true;
            position = "bottom";
            output = [ "eDP-1" ];

            modules-left = [
              "sway/workspaces"
            ];

            modules-center = [ ];

            modules-right = [
              "cava"
              "mpris"
              "pulseaudio"
              "battery"
              "clock"
              "group/misc"
            ];
          }
          // modules-settings;

          additional = {
            mode = "hide";
            ipc = true;
            position = "bottom";
            output = [
              "DP-1"
              "DP-2"
              "DP-3"
              "DP-4"
              "HDMI-1"
              "HDMI-2"
              "HDMI-3"
              "HDMI-4"
            ];

            modules-left = [
              "sway/workspaces"
            ];

            modules-right = [
              "clock"
              "group/misc"
            ];
          }
          // modules-settings;
        };

      style = ''
        #waybar { color: @base00; }
        tooltip { border-color: @base0D; background-color: @base00; }
        tooltip label { color: @base05; }

        #workspaces button { border-bottom: 3px solid transparent; }
        #workspaces button.focused, workspaces button.active { border-bottom: 3px solid @base05; }

        #tray { background-color: @base03; }
        #idle_inhibitor { background-color: @base03; }
        #custom-notifications { background-color: @base03; }

        #clock { background-color: @base03; }

        #battery { color: @base00; background-color: @base0D; }
        #battery.charging { background-color: @base0E; }

        #pulseaudio { color: @base00; background-color: @base09; }
        #pulseaudio.muted { background-color: @base0C; }

        #mpris { color: @base00; background-color: @base0B; }

        #cava { color: @base00; background-color: @base0D; }
      ''
      + ''
        * {
          border-radius: 0;
        }

        /* Apply transparency to the bar */
        #waybar { background: alpha(white, 0); }

        /* Apply margin to all module groups */
        .modules-left, .modules-center, .modules-right {
          /*margin: .5rem .8rem;*/
        }

        /* Apply padding to all modules */
        .modules-right widget .module {
          padding: 0 .7rem;

          color: @base07;
        }

        /* Round first and last child of left, right and center modules. Disable rounding on the sides*/
        .modules-left > widget:last-child .module,
        .modules-center > widget:last-child .module/*,
        .modules-right > widget:last-child .module*/ {
          border-top-right-radius: 5px;
        }
        /*.modules-left > widget:first-child .module,*/
        .modules-center > widget:first-child .module,
        .modules-right > widget:first-child .module {
          border-top-left-radius: 5px;
        }

        /* Round first and last child of workspaces. */
        #workspaces > button:first-child {
          /*border-top-left-radius: 5px;*/
        }
        #workspaces > button:last-child {
          border-top-right-radius: 5px;
        }

        #workspaces button {
          color: @base07;
          background-color: @base03;
        }
        #workspaces button:hover {
          color: @base07;
          background-color: @base03;
        }
        #workspaces button.urgent { color: @base08; }
      '';
    };

    wayland.windowManager.sway.config.bars = [
      {
        command = lib.getExe pkgs.waybar;

        mode = "hide";
        hiddenState = "hide";
      }
    ];
  };
}
