{ config
, lib
, pkgs
, outputs
, ...
}:

with lib;
with builtins;

let
  inherit (outputs) homeManagerModules;

  sway-cfg = config.wayland.windowManager.sway.config;

  workspaces-range = zipListsWith (num: ws: { inherit ws num; }) [ 1 2 3 4 5 6 7 8 9 0 ] (range 1 10);
in
{
  imports = [ homeManagerModules.wl-clip-persist ./swaybar.nix ./xcompose.nix ./search.nix ];

  options = { };

  config = {
    services.wl-clip-persist.enable = true;

    services.mako = with config.colorScheme.colors;
      {
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
        # TODO: this doesn't work find a way to quickly cut output when locked and idle
        {
          timeout = 1;
          command = "if ${getExe' pkgs.busybox "pgrep"} -x swaylock; then ${getExe' pkgs.sway "swaymsg"} \"output * power off\"; fi";
          resumeCommand = "${getExe' pkgs.sway "swaymsg"} \"output * power on\"";
        }

        { timeout = 60 * 5; command = ''${getExe pkgs.chayang} -d5 && ${getExe' pkgs.sway "swaymsg"} "output * power off"''; resumeCommand = ''${getExe' pkgs.sway "swaymsg"} "output * power on"''; }
        { timeout = 60 * 10; command = "${getExe' pkgs.systemd "loginctl"} lock-session"; }
        { timeout = 60 * 15; command = "${getExe' pkgs.systemd "systemctl"} suspend"; }
      ];
      events = [
        { event = "before-sleep"; command = "${getExe pkgs.playerctl} pause"; }
        # Can be triggered with `loginctl lock-session`
        { event = "lock"; command = "${getExe pkgs.swaylock} -feF --indicator-y-position 980 --indicator-x-position 100 -i ${../../assets/BinaryCloud.png}"; }
      ];
    };

    wayland.windowManager.sway = {
      enable = true;
      config = {
        # TODO: support multiple modifier keys
        modifier = "Mod4"; # Super key
        terminal = "${getExe pkgs.kitty}";

        defaultWorkspace = "workspace number 1";

        left = "h";
        down = "j";
        up = "k";
        right = "l";

        fonts = { names = [ "sans-serif" ]; size = 11.0; };

        window = {
          titlebar = false;
          commands = [{
            # Tag of shame
            command = ''title_format "%title <small>[%shell]</small>"'';
            criteria.shell = "^((?!xdg_shell).)*$";
          }];
        };

        startup = [
          { command = "${getExe' pkgs.workstyle "workstyle"} &> /tmp/workstyle.log"; always = true; }
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


        input = {
          "type:keyboard" = {
            xkb_layout = "us,fr";
            xkb_options = "grp:menu_toggle,compose:caps";

            repeat_delay = toString 300;
            repeat_rate = toString 30;
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
        keybindings = foldl (acc: val: acc // val) { }
          (map
            (modifier: {
              "${modifier}+Return" = "exec ${sway-cfg.terminal}";
              "${modifier}+Shift+Return" = "exec ${getExe pkgs.cinnamon.nemo}";
              "${modifier}+Shift+q" = "kill";
              "${modifier}+d" = "exec ${sway-cfg.menu}";
              "${modifier}+Space" = "exec ${getExe' pkgs.mako "makoctl"} dismiss";

              "${modifier}+Escape" = "exec ${getExe' pkgs.systemd "loginctl"} lock-session";
              "${modifier}+Alt+Escape" = "exec ${pkgs.writeShellScript "lock-screenshot.sh" ''
                tmpimg=$(${getExe' pkgs.coreutils "mktemp"} /tmp/lock-bg.XXX)

                # Give some time to hide the bar
                sleep 1
                ${getExe pkgs.grim} $tmpimg
                ${getExe pkgs.swaylock} -feF --image $tmpimg --indicator-y-position 980 --indicator-x-position 100 

                rm $tmpimg
              ''}";

              "${modifier}+${sway-cfg.left}" = "focus left";
              "${modifier}+${sway-cfg.down}" = "focus down";
              "${modifier}+${sway-cfg.up}" = "focus up";
              "${modifier}+${sway-cfg.right}" = "focus right";

              "${modifier}+Shift+${sway-cfg.left}" = "move left";
              "${modifier}+Shift+${sway-cfg.down}" = "move down";
              "${modifier}+Shift+${sway-cfg.up}" = "move up";
              "${modifier}+Shift+${sway-cfg.right}" = "move right";
              "${modifier}+b" = "split vertical";
              "${modifier}+n" = "split horizontal";

              "${modifier}+Alt+${sway-cfg.left}" = "resize shrink width 10 px";
              "${modifier}+Alt+${sway-cfg.down}" = "resize grow height 10 px";
              "${modifier}+Alt+${sway-cfg.up}" = "resize shrink height 10 px";
              "${modifier}+Alt+${sway-cfg.right}" = "resize grow width 10 px";
              "${modifier}+f" = "fullscreen toggle";
              "${modifier}+Shift+space" = "floating toggle";
              # Change between tiling and floating focus
              "${modifier}+Alt+space" = "focus mode_toggle";

              # Screenshotting
              "${modifier}+s" = ''exec ${getExe pkgs.grim} -g "$(${getExe pkgs.slurp})" - | ${getExe' pkgs.wl-clipboard "wl-copy"}'';
              "${modifier}+Shift+s" = "exec ${getExe' pkgs.wl-clipboard "wl-paste"} | ${getExe pkgs.swappy} --file - --output-file - | ${getExe' pkgs.wl-clipboard "wl-copy"}";

              # Soundcontrol Keys
              "--locked XF86AudioPrev" = "exec ${getExe pkgs.playerctl} previous";
              "--locked XF86AudioNext" = "exec ${getExe pkgs.playerctl} next";
              "--locked XF86AudioPlay" = "exec ${getExe pkgs.playerctl} play-pause";
              "--locked XF86AudioStop" = "exec ${getExe pkgs.playerctl} stop";

              # Avizo controled
              "--locked XF86AudioRaiseVolume" = "exec ${getExe' pkgs.avizo "volumectl"} -u up";
              "--locked XF86AudioLowerVolume" = "exec ${getExe' pkgs.avizo "volumectl"} -u down";
              "--locked XF86AudioMute" = "exec ${getExe' pkgs.avizo "volumectl"} toggle-mute";
              "--locked XF86AudioMicMute" = "exec ${getExe' pkgs.avizo "volumectl"} -m toggle-mute";
              "--locked XF86MonBrightnessUp" = "exec ${getExe' pkgs.avizo "lightctl"} up";
              "--locked XF86MonBrightnessDown" = "exec ${getExe' pkgs.avizo "lightctl"} down";
            }
            // listToAttrs (flatten (map
              (num: [
                { name = "${modifier}+${toString num.num}"; value = "workspace number ${toString num.ws}"; }
                { name = "${modifier}+Alt+${toString num.num}"; value = "move container to workspace number ${toString num.ws}"; }
                { name = "${modifier}+Shift+${toString num.num}"; value = "move container to workspace number ${toString num.ws}; workspace number ${toString num.ws}"; }
              ])
              workspaces-range))
            ) [ sway-cfg.modifier ]);
        #   ↑ Maybe have a second key as a modifier (like "Right Alt")
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

      darkModeScripts.gtk-theme = ''${getExe' pkgs.dconf "dconf"} write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"'';
      lightModeScripts.gtk-theme = ''${getExe' pkgs.dconf "dconf"} write /org/gnome/desktop/interface/color-scheme "'prefer-light'"'';
    };

    services.avizo.enable = true;
  };
}
