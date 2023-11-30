{ config
, lib
, pkgs
, ...
}:

with lib;
with builtins;

let
  workspaces-range = zipListsWith (num: ws: { inherit ws num; }) [ 1 2 3 4 5 6 7 8 9 0 ] (range 1 10);
in
{
  config = {
    services.mako = with config.colorScheme.colors; {
      enable = true;

      font = "sans-serif 10";
      backgroundColor = "#${base0D}";
      textColor = "#ffffff";

      icons = true;

      width = 500;
      maxVisible = 5;
      sort = "-priority";

      borderSize = 0;
      borderRadius = 5;

      extraConfig = ''
        [urgency="low"]
        background-color=#${base0A}
        [urgency="critical"]
        background-color=#${base0F}
      '';
    };

    gtk = {
      enable = true;
      theme = {
        name = "Arc-Dark";
        package = pkgs.arc-theme;
      };
      cursorTheme = {
        name = "Bibata-Modern-Ice";
        package = pkgs.bibata-cursors;
      };
      iconTheme = {
        name = "Papirus";
        package = pkgs.papirus-icon-theme;
      };
    };

    services.swayidle = {
      enable = true;
      timeouts = [
        # TODO: this doesnjt work find a way to quickly cut output when locked and idle
        {
          timeout = 1;
          command = "if ${pkgs.busybox}/bin/pgrep -x swaylock; then ${pkgs.sway}/bin/swaymsg \"output * power off\"; fi";
          resumeCommand = "${pkgs.sway}/bin/swaymsg \"output * power on\"";
        }

        { timeout = 60 * 5; command = "${pkgs.sway}/bin/swaymsg \"output * power off\""; resumeCommand = "${pkgs.sway}/bin/swaymsg \"output * power on\""; }
        { timeout = 60 * 10; command = "${pkgs.systemd}/bin/loginctl lock-session"; }
        { timeout = 60 * 15; command = "${pkgs.systemd}/bin/systemctl suspend"; }
      ];
      events = [
        { event = "before-sleep"; command = "${pkgs.playerctl}/bin/playerctl pause"; }
        # Can be triggered with `loginctl lock-session`
        { event = "lock"; command = "${pkgs.swaylock}/bin/swaylock -feF --indicator-y-position 980 --indicator-x-position 100 -i ${../assets/BinaryCloud.png}"; }
      ];
    };

    wayland.windowManager.sway = {
      enable = true;
      config = rec {
        modifier = "Mod4"; # Super key
        terminal = "${pkgs.kitty}/bin/kitty";
        menu = "${pkgs.tofi}/bin/tofi-drun  --font ${pkgs.inter}/share/fonts/opentype/Inter-Regular.otf | xargs swaymsg exec --";

        defaultWorkspace = "workspace number 1";

        left = "h";
        down = "j";
        up = "k";
        right = "l";

        window = {
          titlebar = false;
          commands = [
            {
              # Tag of shame
              command = ''title_format "%title <small>[XWayland]</small>"'';
              criteria = {
                shell = "xwayland";
              };
            }
          ];
        };

        startup = [
          {
            command = "${pkgs.workstyle}/bin/workstyle &> /tmp/workstyle.log";
            always = true;
          }
        ];

        focus.followMouse = false;

        gaps.smartBorders = "no_gaps";

        colors = with config.colorScheme.colors; {
          background = "#${base00}";

          focused = {
            background = "#285577";
            border = "#4c7899";
            childBorder = "#285577";
            indicator = "#2e9ef4";
            text = "#ffffff";
          };

          focusedInactive = {
            background = "#5f676a";
            border = "#333333";
            childBorder = "#5f676a";
            indicator = "#484e50";
            text = "#ffffff";
          };

          placeholder = {
            background = "#0c0c0c";
            border = "#000000";
            childBorder = "#0c0c0c";
            indicator = "#000000";
            text = "#ffffff";
          };

          unfocused = {
            background = "#222222";
            border = "#333333";
            childBorder = "#222222";
            indicator = "#292d2e";
            text = "#888888";
          };

          urgent = {
            background = "#900000";
            border = "#2f343a";
            childBorder = "#900000";
            indicator = "#900000";
            text = "#ffffff";
          };
        };

        bars = [
          {
            statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${config.home.homeDirectory}/${config.xdg.configFile."i3status-rust/config-default.toml".target}";
            hiddenState = "hide";
            mode = "hide";

            colors = with config.colorScheme.colors; {
              background = "#${base00}";
              focusedBackground = "#${base00}";
              separator = "#cccccc";
              focusedSeparator = "#cccccc";
              statusline = "#cccccc";
              focusedStatusline = "#cccccc";

              focusedWorkspace = rec {
                text = "#${base07}";
                background = "#${base0C}";
                border = background;
              };

              inactiveWorkspace = rec {
                text = "#${base05}";
                background = "#${base01}";
                border = background;
              };

              activeWorkspace = rec {
                text = "#${base08}";
                background = "#${base0C}";
                border = background;
              };

              urgentWorkspace = rec {
                text = "#ffffff";
                background = "#${base0F}";
                border = background;
              };

              bindingMode = rec {
                text = "#ffffff";
                background = "#${base0F}";
                border = background;
              };
            };

            # Would be nice to have rounded corners and padding when appearing

            extraConfig = "icon_theme Papirus";
          }
        ];

        input = {
          "type:keyboard" = {
            xkb_layout = "us,fr";
            xkb_options = "grp:menu_toggle,compose:caps";

            repeat_delay = toString 250;
            repeat_rate = toString 45;
          };
        };

        seat = {
          "seat0" = {
            xcursor_theme = "Bibata-Modern-Ice";
            hide_cursor = "when-typing enable";
            # Workaround, because key cannot be included twice
            # Clears cursor after 5s
            "" = "hide_cursor 5000";
          };
        };

        bindkeysToCode = true;
        keybindings = {
          "${modifier}+Return" = "exec ${terminal}";
          "${modifier}+Shift+Return" = "exec ${pkgs.cinnamon.nemo}/bin/nemo";
          "${modifier}+Shift+q" = "kill";
          "${modifier}+d" = "exec ${menu}";
          # Same but run instead of drun mode
          "${modifier}+Shift+d" = "exec ${pkgs.tofi}/bin/tofi-run  --font ${pkgs.inter}/share/fonts/opentype/Inter-Regular.otf | xargs swaymsg exec --";
          "${modifier}+Space" = "exec ${pkgs.mako}/bin/makoctl dismiss";

          "${modifier}+Escape" = "exec loginctl lock-session";

          "${modifier}+${left}" = "focus left";
          "${modifier}+${down}" = "focus down";
          "${modifier}+${up}" = "focus up";
          "${modifier}+${right}" = "focus right";

          "${modifier}+Shift+${left}" = "move left";
          "${modifier}+Shift+${down}" = "move down";
          "${modifier}+Shift+${up}" = "move up";
          "${modifier}+Shift+${right}" = "move right";
          "${modifier}+b" = "split vertical";
          "${modifier}+n" = "split horizontal";

          "${modifier}+r" = "mode resize";
          "${modifier}+f" = "fullscreen toggle";
          "${modifier}+Shift+space" = "floating toggle";

          # Screenshotting
          "${modifier}+s" = ''exec ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy'';
          # TODO: replace swatty by satty
          "${modifier}+Shift+s" = "exec ${pkgs.wl-clipboard}/bin/wl-paste | ${pkgs.swappy}/bin/swappy --file - --output-file - | ${pkgs.wl-clipboard}/bin/wl-copy";


          # Soundcontrol Keys
          XF86AudioPrev = "exec ${pkgs.playerctl}/bin/playerctl previous";
          XF86AudioNext = "exec ${pkgs.playerctl}/bin/playerctl next";
          XF86AudioPlay = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
          XF86AudioStop = "exec ${pkgs.playerctl}/bin/playerctl stop";

          # Avizo controled
          XF86AudioRaiseVolume = "exec ${pkgs.avizo}/bin/volumectl -u up";
          XF86AudioLowerVolume = "exec ${pkgs.avizo}/bin/volumectl -u down";
          XF86AudioMute = "exec ${pkgs.avizo}/bin/volumectl toggle-mute";
          XF86AudioMicMute = "exec ${pkgs.avizo}/bin/volumectl -m toggle-mute";
          XF86MonBrightnessUp = "exec ${pkgs.avizo}/bin/lightctl up";
          XF86MonBrightnessDown = "exec ${pkgs.avizo}/bin/lightctl down";
        }
        // listToAttrs (map (num: { name = "${modifier}+${toString num.num}"; value = "workspace number ${toString num.ws}"; }) workspaces-range)
        // listToAttrs (map (num: { name = "${modifier}+Alt+${toString num.num}"; value = "move container to workspace number ${toString num.ws}"; }) workspaces-range)
        // listToAttrs (map (num: { name = "${modifier}+Shift+${toString num.num}"; value = "move container to workspace number ${toString num.ws}; workspace number ${toString num.ws}"; }) workspaces-range);

        modes = {
          resize = {
            "${left}" = "resize shrink width 10 px";
            "${down}" = "resize grow height 10 px";
            "${up}" = "resize shrink height 10 px";
            "${right}" = "resize grow width 10 px";

            "${modifier}+r" = "mode default";
            "Space" = "mode default";
            "Return" = "mode default";
            "Escape" = "mode default";
          };
        };
      };
    };

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

    services.blueman-applet.enable = true;

    services.poweralertd.enable = true;

    services.wlsunset = {
      enable = true;
      latitude = toString 48.8;
      longitude = toString 2.3;
    };

    services.darkman = {
      enable = true;
      settings = {
        lat = 48.8;
        lng = 2.3;
        usegeoclue = true;
      };
    };

    services.avizo.enable = true;

    # We could've used `(pkgs.formats.toml { }).generate "config.toml" { <opts> }`
    # but this doesn't keep ordering, and ordering is important here
    xdg.configFile."workstyle/config.toml".source = ../assets/workstyle.toml;

    xdg.configFile."tofi/config".text = with config.colorScheme.colors; lib.generators.toKeyValue { } {
      font-size = 14;

      horizontal = true;
      anchor = "top";
      width = "100%";
      height = 48;

      outline-width = 0;
      border-width = 0;

      min-input-width = 100;
      result-spacing = 20;

      padding-top = 12;
      padding-bottom = 12;
      padding-left = 20;
      padding-right = 20;

      text-color = "#${base06}";
      background-color = "#${base00}";

      prompt-text = " ";
      prompt-padding = 30;
      prompt-background = "#${base01}";
      prompt-background-padding = "5, 10";
      prompt-background-corner-radius = 5;

      input-color = "#${base07}";
      input-background = "#${base01}";
      input-background-padding = "5, 10";
      input-background-corner-radius = 5;

      selection-color = "#${base0E}";
      selection-background = "#${base01}";
      selection-background-padding = "5, 10";
      selection-background-corner-radius = 8;
      selection-match-color = "#${base08}";

      clip-to-padding = false;
    };
  };
}

