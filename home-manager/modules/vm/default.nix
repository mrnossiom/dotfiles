{ self
, config
, osConfig
, lib
, pkgs
, ...
}:

with lib;
with builtins;

let
  inherit (self.outputs) homeManagerModules;

  theme = config.colorScheme.palette;
  swayCfg = config.wayland.windowManager.sway.config;

  workspacesRange = zipListsWith (num: ws: { inherit ws num; }) [ 1 2 3 4 5 6 7 8 9 0 ] (range 1 10);
in
{
  imports = [
    homeManagerModules.wl-clip-persist

    ./swaybar.nix
    ./xcompose.nix
    ./search.nix
  ];

  config = {
    # TODO: seems to have troubles with encoding
    # services.wl-clip-persist.enable = true;

    programs.swaylock = {
      enable = true;
      settings =
        let
          cfg = osConfig.local.screen or null;
        in
        {
          daemonize = true;
          ignore-empty-password = true;
          show-failed-attempts = true;

          image = toString ../../assets/BinaryCloud.png;
        }
        // optionalAttrs (cfg != null) {
          indicator-y-position = ((cfg.height * 0.9) / cfg.scale);
          indicator-x-position = 100;
        };
    };

    services.mako = {
      enable = true;

      font = "sans-serif 10";
      backgroundColor = "#${theme.base0D}";
      textColor = "#ffffff";

      icons = true;

      width = 500;
      maxVisible = 5;
      sort = "-priority";

      borderSize = 0;
      borderRadius = 5;

      extraConfig = ''
        [urgency="low"]
        background-color=#${theme.base0A}
        [urgency="critical"]
        background-color=#${theme.base0F}
      '';
    };

    gtk = {
      enable = true;

      gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

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
          timeout = 10;
          command = "if ${getExe' pkgs.busybox "pgrep"} -x swaylock; then ${getExe' pkgs.sway "swaymsg"} \"output * power off\"; fi";
          resumeCommand = "${getExe' pkgs.sway "swaymsg"} \"output * power on\"";
        }

        {
          timeout = 60 * 5;
          # ——————————————— Dims the screen for n seconds ↓↓ and then switch it off
          command = ''${getExe pkgs.chayang} -d${toString 10} && ${getExe' pkgs.sway "swaymsg"} "output * power off"'';
          resumeCommand = ''${getExe' pkgs.sway "swaymsg"} "output * power on"'';
        }
        { timeout = 60 * 10; command = "${getExe' pkgs.systemd "loginctl"} lock-session"; }
        { timeout = 60 * 15; command = "${getExe' pkgs.systemd "systemctl"} suspend"; }
      ];
      events = [
        { event = "before-sleep"; command = "${getExe pkgs.playerctl} pause"; }
        { event = "before-sleep"; command = "${getExe' pkgs.systemd "loginctl"} lock-session"; }
        # Can be triggered with `loginctl lock-session`
        { event = "lock"; command = getExe pkgs.swaylock; }
      ];
    };

    wayland.windowManager.sway = {
      enable = true;
      config = {
        modifier = "Mod4"; # Super key
        terminal = config.home.sessionVariables.TERMINAL;

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

        focus.followMouse = false;

        gaps.smartBorders = "no_gaps";

        colors = {
          background = "#${theme.base00}";

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
          "type:touchpad" = { events = "disabled_on_external_mouse"; };

          # Disable touchscreen by default
          "type:touch" = { events = "disabled"; };
        };

        output."*".bg = "#000000 solid_color";

        seat = {
          "seat0" = {
            xcursor_theme = "Bibata-Modern-Ice";
            # Clears cursor after 5s
            hide_cursor = toString (5 * 1000);
            # Workaround, because key cannot be included twice
            # disable cursor when typing
            "" = "hide_cursor when-typing enable";
          };
        };

        bindkeysToCode = true;
        keybindings =
          let
            pamixer = getExe pkgs.pamixer;
            playerctl = getExe pkgs.playerctl;
            brightnessctl = getExe pkgs.brightnessctl;
          in
          foldl (acc: val: acc // val) { }
            (map
              (modifier: {
                "${modifier}+Return" = "exec ${swayCfg.terminal}";
                "${modifier}+Shift+Return" = "exec ${getExe' pkgs.gnome.nautilus "nautilus"}";
                "${modifier}+Shift+q" = "kill";
                "${modifier}+d" = "exec ${swayCfg.menu}";
                "${modifier}+Space" = "exec ${getExe' pkgs.mako "makoctl"} dismiss";

                "${modifier}+Escape" = "exec ${getExe' pkgs.systemd "loginctl"} lock-session";
                "${modifier}+Alt+Escape" = "exec ${pkgs.writeShellScript "lock-screenshot.sh" ''
                  tmpimg=$(${getExe' pkgs.coreutils "mktemp"} /tmp/lock-bg.XXX)

                  # Give some time to hide the bar
                  sleep 1

                  ${getExe pkgs.grim} $tmpimg
                  ${getExe pkgs.swaylock} --image $tmpimg

                  rm $tmpimg
                ''}";

                "${modifier}+${swayCfg.left}" = "focus left";
                "${modifier}+${swayCfg.down}" = "focus down";
                "${modifier}+${swayCfg.up}" = "focus up";
                "${modifier}+${swayCfg.right}" = "focus right";

                "${modifier}+Shift+${swayCfg.left}" = "move left";
                "${modifier}+Shift+${swayCfg.down}" = "move down";
                "${modifier}+Shift+${swayCfg.up}" = "move up";
                "${modifier}+Shift+${swayCfg.right}" = "move right";
                "${modifier}+b" = "split vertical";
                "${modifier}+n" = "split horizontal";

                "${modifier}+Alt+${swayCfg.left}" = "resize shrink width 10 px";
                "${modifier}+Alt+${swayCfg.down}" = "resize grow height 10 px";
                "${modifier}+Alt+${swayCfg.up}" = "resize shrink height 10 px";
                "${modifier}+Alt+${swayCfg.right}" = "resize grow width 10 px";
                "${modifier}+f" = "fullscreen toggle";
                "${modifier}+Shift+space" = "floating toggle";
                # Change between tiling and floating focus
                "${modifier}+Alt+space" = "focus mode_toggle";
                "${modifier}+Alt+c" = "move position cursor";
                "${modifier}+p" = "sticky toggle";

                # Screenshotting
                "${modifier}+s" = ''exec ${getExe pkgs.grim} -g "$(${getExe pkgs.slurp})" - | ${getExe' pkgs.wl-clipboard "wl-copy"}'';
                "${modifier}+Shift+s" = "exec ${getExe' pkgs.wl-clipboard "wl-paste"} | ${getExe pkgs.swappy} --file - --output-file - | ${getExe' pkgs.wl-clipboard "wl-copy"}";

                # Soundcontrol Keys
                "--locked XF86AudioPrev" = "exec ${playerctl} previous";
                "--locked XF86AudioNext" = "exec ${playerctl} next";
                "--locked XF86AudioPlay" = "exec ${playerctl} play-pause";
                "--locked XF86AudioStop" = "exec ${playerctl} stop";
                "--locked XF86AudioRaiseVolume" = "exec ${pamixer} --unmute --increase 5";
                "--locked XF86AudioLowerVolume" = "exec ${pamixer} --unmute --decrease 5";
                "--locked XF86AudioMute" = "exec ${pamixer} --toggle-mute";
                "--locked XF86AudioMicMute" = "exec ${pamixer} --default-source --toggle-mute";
                "--locked XF86MonBrightnessUp" = "exec ${brightnessctl} set 5%+";
                "--locked XF86MonBrightnessDown" = "exec ${brightnessctl} set 5%- --min-value=5";
                "--locked XF86TouchpadToggle" = ''input "type:touchpad" events toggle enabled disabled_on_external_mouse'';
              }
              // listToAttrs (flatten (map
                (num: [
                  { name = "${modifier}+${toString num.num}"; value = "workspace number ${toString num.ws}"; }
                  { name = "${modifier}+Alt+${toString num.num}"; value = "move container to workspace number ${toString num.ws}"; }
                  { name = "${modifier}+Shift+${toString num.num}"; value = "move container to workspace number ${toString num.ws}; workspace number ${toString num.ws}"; }
                ])
                workspacesRange))
              ) [ swayCfg.modifier ]);
        #   ↑ Maybe have a second key as a modifier (like "Right Alt")
      };
    };

    services.blueman-applet.enable = true;

    services.poweralertd.enable = true;

    services.darkman = {
      enable = true;
      settings.usegeoclue = true;

      darkModeScripts.gtk-theme = ''${getExe pkgs.dconf} write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"'';
      lightModeScripts.gtk-theme = ''${getExe pkgs.dconf} write /org/gnome/desktop/interface/color-scheme "'prefer-light'"'';
    };

    services.gammastep = {
      enable = true;
      provider = "geoclue2";
      settings.general = {
        adjustment-method = "wayland";
        gamma = 0.8;
      };
    };
  };
}
