{ self
, config
, lib
, pkgs
, upkgs
, ...
}:

let
  inherit (self.outputs) homeManagerModules;

  cfg = config.local.fragment.vm;

  theme = config.local.colorScheme.palette;
  cfg-sway = config.wayland.windowManager.sway.config;

  workspacesRange = lib.zipListsWith (key-idx: workspace-idx: { inherit key-idx workspace-idx; }) [ 1 2 3 4 5 6 7 8 9 0 ] (lib.range 1 10);
in
{
  imports = [
    homeManagerModules.wl-clip-persist
  ];

  options.local.fragment.vm.enable = lib.mkEnableOption ''
    Sway related
  '';

  config = lib.mkIf cfg.enable {
    # TODO: seems to have troubles with encoding
    # services.wl-clip-persist.enable = true;

    programs.swaylock = {
      enable = true;
      settings = {
        daemonize = true;
        ignore-empty-password = true;
        show-failed-attempts = true;

        image = toString ../../assets/wallpaper-binary-cloud.png;

        indicator-y-position = -100;
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
      maxVisible = 3;
      sort = "-priority";

      layer = "overlay";

      borderSize = 0;
      borderRadius = 5;

      extraConfig = ''
        [urgency="low"]
        background-color=#${theme.base0A}
        [urgency="critical"]
        background-color=#${theme.base0F}

        [mode="dnd"]
        invisible=1
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

    services.swayidle =
      let
        pgrep = lib.getExe' pkgs.busybox "pgrep";
        swaymsg = lib.getExe' config.wayland.windowManager.sway.package "swaymsg";
        loginctl = lib.getExe' pkgs.systemd "loginctl";
        systemctl = lib.getExe' pkgs.systemd "systemctl";
      in
      {
        enable = true;
        timeouts = [
          # TODO: this doesn't work find a way to quickly cut output when locked and idle
          {
            timeout = 10;
            command = "if ${pgrep} -x swaylock; then ${swaymsg} \"output * power off\"; fi";
            resumeCommand = "${swaymsg} \"output * power on\"";
          }

          {
            timeout = 60 * 5;
            # ——————————————— Dims the screen for n seconds ↓↓ and then switch it off
            command = ''${lib.getExe pkgs.chayang} -d${toString 10} && ${swaymsg} "output * power off"'';
            resumeCommand = ''${swaymsg} "output * power on"'';
          }
          { timeout = 60 * 10; command = "${loginctl} lock-session"; }
          { timeout = 60 * 15; command = "${systemctl} suspend"; }
        ];
        events = [
          { event = "before-sleep"; command = "${lib.getExe pkgs.playerctl} pause"; }
          { event = "before-sleep"; command = "${loginctl} lock-session"; }
          # Can be triggered with `loginctl lock-session`
          { event = "lock"; command = lib.getExe pkgs.swaylock; }
        ];
      };

    wayland.windowManager.sway = {
      enable = true;

      package = upkgs.sway;

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
          commands = [
            # Tag of shame
            {
              # Equivalent to `[shell="xwayland"] title_format "%title [XWayland]"` but for all other shells
              criteria.shell = "^((?!xdg_shell).)*$";
              command = ''title_format "%title <small>[%shell]</small>"'';
            }

            # Toggle floating mode for some specific windows
            {
              # TODO: Bitwarden window glitches on opening
              criteria = { app_id = "^firefox$"; title = "Bitwarden Password Manager"; };
              command = ''floating enable'';
            }
            {
              # Toggles floating for every Unity window but the main one
              # Only the main window begins with `Unity - `
              criteria = { title = "^((?!^Unity - ).)*$"; class = "^Unity$"; instance = "^Unity$"; };
              command = ''floating enable'';
            }

            # Inhibit IDLE when these are fullscreen
            { criteria.app_id = "firefox"; command = "inhibit_idle fullscreen"; }
            { criteria.app_id = "mpv"; command = "inhibit_idle fullscreen"; }
          ];
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
            xkb_layout = "us,fr(ergol),fr";

            # List of all options: https://www.mankier.com/7/xkeyboard-config#Options
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
            pamixer = lib.getExe pkgs.pamixer;
            playerctl = lib.getExe pkgs.playerctl;
            brightnessctl = lib.getExe pkgs.brightnessctl;
            makoctl = lib.getExe' pkgs.mako "makoctl";

            grim = lib.getExe pkgs.grim;
            slurp = lib.getExe pkgs.slurp;
            wl-copy = lib.getExe' pkgs.wl-clipboard "wl-copy";
            wl-paste = lib.getExe' pkgs.wl-clipboard "wl-paste";
          in
          lib.foldl (acc: val: acc // val) { }
            (map
              (modifier: {
                "${modifier}+Return" = "exec ${cfg-sway.terminal}";
                "${modifier}+Shift+Return" = "exec ${lib.getExe' pkgs.gnome.nautilus "nautilus"}";
                "${modifier}+Shift+q" = "kill";
                "${modifier}+d" = "exec ${cfg-sway.menu}";
                "${modifier}+Space" = "exec ${makoctl} dismiss";

                "${modifier}+Escape" = "exec ${lib.getExe' pkgs.systemd "loginctl"} lock-session";
                "${modifier}+Alt+Escape" = "exec ${pkgs.writeShellScript "lock-screenshot.sh" ''
                  tmpimg=$(${lib.getExe' pkgs.coreutils "mktemp"} /tmp/lock-bg.XXX)

                  # Give some time to hide the bar
                  sleep 1

                  ${grim} $tmpimg
                  ${lib.getExe pkgs.swaylock} --image $tmpimg

                  rm $tmpimg
                ''}";

                "${modifier}+${cfg-sway.left}" = "focus left";
                "${modifier}+${cfg-sway.down}" = "focus down";
                "${modifier}+${cfg-sway.up}" = "focus up";
                "${modifier}+${cfg-sway.right}" = "focus right";

                "${modifier}+Shift+${cfg-sway.left}" = "move left";
                "${modifier}+Shift+${cfg-sway.down}" = "move down";
                "${modifier}+Shift+${cfg-sway.up}" = "move up";
                "${modifier}+Shift+${cfg-sway.right}" = "move right";
                "${modifier}+b" = "split vertical";
                "${modifier}+n" = "split horizontal";

                "${modifier}+Alt+${cfg-sway.left}" = "resize shrink width 10 px";
                "${modifier}+Alt+${cfg-sway.down}" = "resize grow height 10 px";
                "${modifier}+Alt+${cfg-sway.up}" = "resize shrink height 10 px";
                "${modifier}+Alt+${cfg-sway.right}" = "resize grow width 10 px";
                "${modifier}+f" = "fullscreen toggle";
                "${modifier}+Shift+space" = "floating toggle";
                # Change between tiling and floating focus
                "${modifier}+Alt+space" = "focus mode_toggle";
                "${modifier}+Alt+c" = "move position cursor";
                "${modifier}+p" = "sticky toggle";

                # Screenshotting
                "${modifier}+s" = ''exec ${grim} -g "$(${slurp})" - | ${wl-copy}'';
                "${modifier}+Shift+s" = "exec ${wl-paste} | ${lib.getExe pkgs.swappy} --file - --output-file - | ${wl-copy}";

                # Soundcontrol Keys
                "--locked XF86AudioPrev" = "exec ${playerctl} previous";
                "--locked XF86AudioNext" = "exec ${playerctl} next";
                "--locked XF86AudioPlay" = "exec ${playerctl} play-pause";
                "--locked XF86AudioStop" = "exec ${playerctl} stop";
                "--locked XF86AudioRaiseVolume" = "exec ${pamixer} --unmute --increase 5";
                "--locked XF86AudioLowerVolume" = "exec ${pamixer} --unmute --decrease 5";
                "--locked XF86AudioMute" = "exec ${pamixer} --toggle-mute";
                "--locked XF86AudioMicMute" = "exec ${pamixer} --default-source --toggle-mute";
                "--locked XF86MonBrightnessUp" = "exec ${brightnessctl} --exponent set 5%+";
                "--locked XF86MonBrightnessDown" = "exec ${brightnessctl} --exponent  set 5%- --min-value=1";
                "--locked XF86TouchpadToggle" = ''input "type:touchpad" events toggle enabled disabled_on_external_mouse'';
              }
              // lib.listToAttrs (lib.flatten (map
                ({ key-idx, workspace-idx }: [
                  { name = "${modifier}+${toString key-idx}"; value = "workspace number ${toString workspace-idx}"; }
                  { name = "${modifier}+Alt+${toString key-idx}"; value = "move container to workspace number ${toString workspace-idx}"; }
                  { name = "${modifier}+Shift+${toString key-idx}"; value = "move container to workspace number ${toString workspace-idx}; workspace number ${toString workspace-idx}"; }
                ])
                workspacesRange))
              ) [ cfg-sway.modifier ]);
      };
    };

    services.blueman-applet.enable = true;

    services.poweralertd.enable = true;

    services.darkman = {
      enable = true;
      package = upkgs.darkman;
      settings.usegeoclue = true;

      darkModeScripts.gtk-theme = ''
        # Change system theme scheme to dark
        ${lib.getExe pkgs.dconf} write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"

        # Do not change brightness as I'm usually on my computer as this time
      '';

      lightModeScripts.gtk-theme = ''
        # Change system theme scheme to light
        ${lib.getExe pkgs.dconf} write /org/gnome/desktop/interface/color-scheme "'prefer-light'"

        # Prepare laptop for wake: set full brightness and disable kbd backlight
        ${lib.getExe pkgs.brightnessctl} --class backlight set 100%
        ${lib.getExe pkgs.brightnessctl} --class leds --device "*::kbd_backlight" set 0%
      '';
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
