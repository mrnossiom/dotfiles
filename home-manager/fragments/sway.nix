{
  config,
  lib,
  pkgs,
  lpkgs,

  isDarwin,
  ...
}:

let
  inherit (config.local) flags;
  cfg = config.local.fragment.sway;
  cfg-sway = config.wayland.windowManager.sway.config;

  workspacesRange = lib.zipListsWith (key-idx: workspace-idx: { inherit key-idx workspace-idx; }) (
    (lib.range 1 9) ++ [ 0 ]
  ) (lib.range 1 10);
in
{
  options.local.fragment.sway.enable = lib.mkEnableOption ''
    Sway related
  '';

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !isDarwin;
        message = "this is a non-darwin fragment";
      }
    ];

    programs.swaylock = {
      enable = true;
      package = if !flags.onlyCached then lpkgs.swaylock else pkgs.swaylock;
      settings = {
        ignore-empty-password = true;
        show-failed-attempts = true;

        # relies on custom swaylock version in `overlays/patches.nix`
        indicator-y-position = if !flags.onlyCached then -100 else 100;
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
        width = 500;
        max-visible = 5;
        sort = "-priority";

        default-timeout = 3 * 1000;

        layer = "overlay";

        border-size = 2;
        border-radius = 5;

        "mode=dnd".invisible = 1;

        "urgency=critical" = {
          invisible = 0;
          default-timeout = 0;
        };
      };
    };

    gtk = {
      enable = true;
      gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    };

    services.swayidle =
      let
        loginctl = lib.getExe' pkgs.systemd "loginctl";
        playerctl = lib.getExe pkgs.playerctl;
        swaymsg = lib.getExe' config.wayland.windowManager.sway.package "swaymsg";

        display = status: ''${swaymsg} "output * power ${status}"'';
        lock = "${lib.getExe config.programs.swaylock.package} --daemonize";
      in
      {
        enable = true;

        timeouts = [
          {
            # Dims the screen for X seconds and then switch it off
            timeout = 5 * 60 - 10;
            command = ''${lib.getExe pkgs.chayang} -d${toString 10}'';
          }
          {
            timeout = 5 * 60;
            command = display "off";
            resumeCommand = display "on";
          }
          {
            timeout = 10 * 60;
            command = "${loginctl} lock-session";
          }
          {
            timeout = 15 * 60;
            command = "${lib.getExe' pkgs.systemd "systemctl"} suspend";
          }
        ];
        events = [
          {
            event = "before-sleep";
            command = "${playerctl} pause; ${display "off"}; ${loginctl} lock-session";
          }
          {
            event = "after-resume";
            command = display "on";
          }
          {
            event = "lock";
            command = lock;
          }
          {
            event = "unlock";
            command = display "on";
          }
        ];
      };

    wayland.windowManager.sway = {
      enable = true;

      xwayland = true; # explicit, op is true by default

      config = {
        modifier = "Super";
        terminal = config.home.sessionVariables.TERMINAL;

        defaultWorkspace = "workspace number 1";

        left = "h";
        down = "j";
        up = "k";
        right = "l";

        window = {
          titlebar = false;
          commands =
            let
              inhibitIdle = appId: behaviour: {
                criteria.app_id = "^${appId}$";
                command = "inhibit_idle ${behaviour}";
              };
            in
            [
              # Tag of shame
              {
                # Equivalent to `[shell="xwayland"] title_format "%title [XWayland]"` but for all other shells
                criteria.shell = "^((?!xdg_shell).)*$";
                command = ''title_format "%title <small>[%shell]</small>"'';
              }

              # Toggle floating mode for some specific windows
              {
                # Toggles floating for every Unity window but the main one
                # Only the main window begins with `Unity - `
                criteria = {
                  title = "^((?!^Unity - ).)*$";
                  class = "^Unity$";
                  instance = "^Unity$";
                };
                command = ''floating enable'';
              }

              # Inhibit IDLE when these are in fullscreen or focused
              (inhibitIdle "firefox" "fullscreen")
              (inhibitIdle "zen-beta" "fullscreen")
              (inhibitIdle "spotify" "fullscreen")
              (inhibitIdle "mpv" "focus")
              (inhibitIdle "org.jellyfin.JellyfinDesktop" "focus")
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

          "type:touchpad" = {
            dwt = "enabled";
            tap = "enabled";
            tap_button_map = "lrm";
          };

          # Split keyboard also acts as a mouse
          # "type:touchpad" = { events = "disabled_on_external_mouse"; };

          # Disable touchscreen by default
          "type:touch" = {
            events = "disabled";
          };
        };

        output."*".bg = lib.mkForce "#000000 solid_color";

        seat."*" = {
          # disable cursor when typing or on purpose
          hide_cursor = "when-typing enable";
        };

        bindkeysToCode = true;
        keybindings =
          let
            mod = cfg-sway.modifier;

            pamixer = lib.getExe pkgs.pamixer;
            playerctl = lib.getExe pkgs.playerctl;
            loginctl = lib.getExe' pkgs.systemd "loginctl";
            brightnessctl = lib.getExe pkgs.brightnessctl;
            nautilus = lib.getExe pkgs.nautilus;
            makoctl = lib.getExe' pkgs.mako "makoctl";

            grim = lib.getExe pkgs.grim;
            slurp = lib.getExe pkgs.slurp;
            swappy = lib.getExe pkgs.swappy;
            wl-copy = lib.getExe' pkgs.wl-clipboard "wl-copy";
            wl-paste = lib.getExe' pkgs.wl-clipboard "wl-paste";
          in
          {
            "${mod}+Return" = "exec ${cfg-sway.terminal}";
            "${mod}+Shift+Return" = "exec ${nautilus}";
            "${mod}+Shift+q" = "kill";
            "${mod}+d" = "exec ${cfg-sway.menu}";
            "${mod}+Space" = "exec ${makoctl} dismiss";

            "${mod}+Escape" = "exec ${loginctl} lock-session";
            "${mod}+Alt+Escape" = "exec ${pkgs.writeShellScript "lock-screenshot.sh" ''
              tmpimg=$(${lib.getExe' pkgs.coreutils "mktemp"} /tmp/lock-bg.XXX)

              # Give some time to hide the bar
              sleep 1

              ${grim} $tmpimg
              ${lib.getExe config.programs.swaylock.package} --image $tmpimg

              rm $tmpimg
            ''}";

            "${mod}+t" = ''input "type:touch" events toggle'';

            "${mod}+${cfg-sway.left}" = "focus left";
            "${mod}+${cfg-sway.down}" = "focus down";
            "${mod}+${cfg-sway.up}" = "focus up";
            "${mod}+${cfg-sway.right}" = "focus right";

            "${mod}+Shift+${cfg-sway.left}" = "move left";
            "${mod}+Shift+${cfg-sway.down}" = "move down";
            "${mod}+Shift+${cfg-sway.up}" = "move up";
            "${mod}+Shift+${cfg-sway.right}" = "move right";
            "${mod}+b" = "split vertical";
            "${mod}+n" = "split horizontal";

            "${mod}+Alt+${cfg-sway.left}" = "resize shrink width 60 px";
            "${mod}+Alt+${cfg-sway.down}" = "resize grow height 60 px";
            "${mod}+Alt+${cfg-sway.up}" = "resize shrink height 60 px";
            "${mod}+Alt+${cfg-sway.right}" = "resize grow width 60 px";
            "${mod}+f" = "fullscreen toggle";
            "${mod}+Shift+space" = "floating toggle";
            # Change between tiling and floating focus
            "${mod}+Alt+space" = "focus mode_toggle";
            "${mod}+Alt+c" = "move position cursor";
            "${mod}+p" = "sticky toggle";

            # Screenshotting
            "${mod}+s" = ''exec ${grim} -g "$(${slurp})" - | ${wl-copy}'';
            "${mod}+Shift+s" = "exec ${wl-paste} | ${swappy} --file - --output-file - | ${wl-copy}";

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
            "--locked XF86TouchpadToggle" =
              ''input "type:touchpad" events toggle enabled disabled_on_external_mouse'';
          }
          // lib.listToAttrs (
            lib.flatten (
              map (
                { key-idx, workspace-idx }:
                [
                  {
                    name = "${mod}+${toString key-idx}";
                    value = "workspace number ${toString workspace-idx}";
                  }
                  {
                    name = "${mod}+Alt+${toString key-idx}";
                    value = "move container to workspace number ${toString workspace-idx}";
                  }
                  {
                    name = "${mod}+Shift+${toString key-idx}";
                    value = "move container to workspace number ${toString workspace-idx}; workspace number ${toString workspace-idx}";
                  }
                ]
              ) workspacesRange
            )
          );
      };
    };

    services.blueman-applet.enable = true;

    services.poweralertd.enable = true;

    services.darkman =
      let
        dconf = lib.getExe pkgs.dconf;
        brightnessctl = lib.getExe pkgs.brightnessctl;
      in
      {
        enable = true;
        settings.usegeoclue = true;

        darkModeScripts.gtk-theme = ''
          # Change system theme scheme to dark
          ${dconf} write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"

          # Do not change brightness as I'm usually on my computer as this time
        '';

        lightModeScripts.gtk-theme = ''
          # Change system theme scheme to light
          ${dconf} write /org/gnome/desktop/interface/color-scheme "'prefer-light'"

          # TODO: change config specialization

          # Prepare laptop for wake: set full brightness and disable kbd backlight
          ${brightnessctl} --class backlight set 100%
          ${brightnessctl} --class leds --device "*::kbd_backlight" set 0%
        '';
      };

    services.gammastep = {
      enable = true;
      tray = true;
      provider = "geoclue2";
      settings.general = {
        adjustment-method = "wayland";
        gamma = 0.8;
      };
    };
  };
}
