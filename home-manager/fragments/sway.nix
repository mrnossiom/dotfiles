{ self
, config
, lib
, pkgs

, isDarwin
, ...
}:

let
  inherit (self.outputs) homeManagerModules;

  cfg = config.local.fragment.sway;

  theme = config.lib.stylix.colors;
  cfg-sway = config.wayland.windowManager.sway.config;

  workspacesRange = lib.zipListsWith (key-idx: workspace-idx: { inherit key-idx workspace-idx; }) [ 1 2 3 4 5 6 7 8 9 0 ] (lib.range 1 10);
in
{
  imports = [
    homeManagerModules.wl-clip-persist
  ];

  options.local.fragment.sway.enable = lib.mkEnableOption ''
    Sway related
  '';

  config = lib.mkIf cfg.enable {
    assertions = [
      { assertion = !isDarwin; message = "this is a non-darwin fragment"; }
    ];

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

    programs.fish.loginShellInit = ''
      if test (id --user $USER) -ge 1000 && test (tty) = "/dev/tty1"
        exec sway 2> /tmp/sway.(date -u +%Y-%m-%dT%H:%M:%S).log
      end
    '';

    services.mako = {
      enable = true;
      settings = {
        icons = true;

        width = 500;
        max-visible = 3;
        sort = "-priority";

        default-timeout = 5000;

        layer = "overlay";

        border-size = 0;
        border-radius = 5;

        "urgency=critical" = {
          background-color = theme.withHashtag.base0F;
        };

        "mode=dnd" = {
          invisible = 1;
        };
      };
    };

    gtk = {
      enable = true;

      gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

      iconTheme = { name = "Papirus"; package = pkgs.papirus-icon-theme; };
    };

    services.swayidle =
      let
        swaymsg = lib.getExe' config.wayland.windowManager.sway.package "swaymsg";
        loginctl = lib.getExe' pkgs.systemd "loginctl";
        systemctl = lib.getExe' pkgs.systemd "systemctl";
      in
      {
        enable = true;
        timeouts = [
          # TODO: this doesn't work find a way to quickly cut output when locked and idle
          # {
          #   timeout = 10;
          #   command = "if ${pgrep} -x swaylock; then ${swaymsg} \"output * power off\"; fi";
          #   resumeCommand = "${swaymsg} \"output * power on\"";
          # }

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

      xwayland = true; # explicit, op is true by default

      config = {
        modifier = "Mod4"; # Super key
        terminal = config.home.sessionVariables.TERMINAL;

        defaultWorkspace = "workspace number 1";

        left = "h";
        down = "j";
        up = "k";
        right = "l";

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
            { criteria.app_id = "spotify"; command = "inhibit_idle fullscreen"; }
          ];
        };

        focus.followMouse = false;

        gaps.smartBorders = "no_gaps";

        input = {
          "type:keyboard" = {
            xkb_layout = "us,fr(ergol),fr";

            # List of all options: https://www.mankier.com/7/xkeyboard-config#Options
            xkb_options = "grp:menu_toggle,compose:caps";

            repeat_delay = toString 300;
            repeat_rate = toString 30;
          };

          # Split keyboard also acts as a mouse
          # "type:touchpad" = { events = "disabled_on_external_mouse"; };

          # Disable touchscreen by default
          "type:touch" = { events = "disabled"; };
        };

        output."*".bg = "#000000 solid_color";

        seat = {
          "seat0" = {
            xcursor_theme = "Bibata-Modern-Ice";
            # disable cursor when typing or on purpose
            hide_cursor = "when-typing enable";
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
                "${modifier}+Shift+Return" = "exec ${lib.getExe' pkgs.nautilus "nautilus"}";
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

                "${modifier}+Alt+${cfg-sway.left}" = "resize shrink width 60 px";
                "${modifier}+Alt+${cfg-sway.down}" = "resize grow height 60 px";
                "${modifier}+Alt+${cfg-sway.up}" = "resize shrink height 60 px";
                "${modifier}+Alt+${cfg-sway.right}" = "resize grow width 60 px";
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
      settings.usegeoclue = true;

      darkModeScripts.gtk-theme = ''
        # Change system theme scheme to dark
        ${lib.getExe pkgs.dconf} write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"

        # Do not change brightness as I'm usually on my computer as this time
      '';

      lightModeScripts.gtk-theme = ''
        # Change system theme scheme to light
        ${lib.getExe pkgs.dconf} write /org/gnome/desktop/interface/color-scheme "'prefer-light'"

        # TODO: change config specialization

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
