{
  self,
  config,
  lib,
  pkgs,
  upkgs,
  ...
}:

let
  inherit (self.inputs) niri;

  cfg = config.local.fragment.niri;
  noctalia-bin = lib.getExe config.programs.noctalia-shell.package;
in

{
  options.local.fragment.niri.enable = lib.mkEnableOption ''
    Niri related
  '';

  imports = [ niri.homeModules.niri ];

  config = lib.mkIf cfg.enable {
    programs.niri = {
      enable = true;
      package = upkgs.niri;

      settings = {
        spawn-at-startup = [
          { command = [ noctalia-bin ]; }
        ];

        layout = {
          gaps = 5;
          border.width = 0;
          focus-ring = {
            width = 0;
          };
        };

        prefer-no-csd = true;

        animations.enable = false;

        window-rules = [
          {
            geometry-corner-radius = null;
            clip-to-geometry = true;
          }
        ];

        input = {
          keyboard.xkb = {
            layout = "us,fr";
            options = "grp:menu_toggle,compose:caps";
          };
          touchpad = {
            tap = true;
            natural-scroll = false;
          };
        };

        outputs."eDP-1".scale = 2.0;

        binds =
          let
            noctalia-call =
              cmd:
              [
                "${noctalia-bin}"
                "ipc"
                "call"
              ]
              ++ (pkgs.lib.splitString " " cmd);
          in
          {
            "Mod+Return".action.spawn = [ "${lib.getExe config.programs.kitty.package}" ];
            "Mod+Shift+Return".action.spawn = [ "${lib.getExe pkgs.nautilus}" ];

            "Mod+D".action.spawn = noctalia-call "launcher toggle";

            "Mod+Shift+Q".action.close-window = [ ];
            "Mod+Escape".action.spawn = noctalia-call "lockScreen lock";
            "Mod+Space".action.spawn = [
              "makoctl"
              "dismiss"
            ];

            "Mod+Shift+Space".action.toggle-window-floating = [ ];
            "Mod+F".action.fullscreen-window = [ ];

            "Mod+H".action.focus-column-left = [ ];
            "Mod+L".action.focus-column-right = [ ];
            "Mod+K".action.focus-window-up = [ ];
            "Mod+J".action.focus-window-down = [ ];

            "Mod+Shift+H".action.move-column-left = [ ];
            "Mod+Shift+L".action.move-column-right = [ ];
            "Mod+Shift+K".action.move-window-up = [ ];
            "Mod+Shift+J".action.move-window-down = [ ];

            "Mod+1".action.focus-workspace = 1;
            "Mod+2".action.focus-workspace = 2;
            "Mod+3".action.focus-workspace = 3;
            "Mod+4".action.focus-workspace = 4;
            "Mod+5".action.focus-workspace = 5;
            "Mod+6".action.focus-workspace = 6;
            "Mod+7".action.focus-workspace = 7;
            "Mod+8".action.focus-workspace = 8;
            "Mod+9".action.focus-workspace = 9;

            "Mod+Shift+1".action.move-column-to-workspace = 1;
            "Mod+Shift+2".action.move-column-to-workspace = 2;
            "Mod+Shift+3".action.move-column-to-workspace = 3;
            "Mod+Shift+4".action.move-column-to-workspace = 4;
            "Mod+Shift+5".action.move-column-to-workspace = 5;
            "Mod+Shift+6".action.move-column-to-workspace = 6;
            "Mod+Shift+7".action.move-column-to-workspace = 7;
            "Mod+Shift+8".action.move-column-to-workspace = 8;
            "Mod+Shift+9".action.move-column-to-workspace = 9;

            "Mod+Ctrl+H".action.set-column-width = "-10%";
            "Mod+Ctrl+L".action.set-column-width = "+10%";
            "Mod+Ctrl+K".action.set-window-height = "-10%";
            "Mod+Ctrl+J".action.set-window-height = "+10%";

            "XF86AudioNext".action.spawn = [
              "playerctl"
              "next"
            ];
            "XF86AudioPrev".action.spawn = [
              "playerctl"
              "previous"
            ];
            "XF86AudioPlay".action.spawn = [
              "playerctl"
              "play-pause"
            ];
            "XF86AudioRaiseVolume".action.spawn = [
              "wpctl"
              "set-volume"
              "@DEFAULT_AUDIO_SINK@"
              "5%+"
            ];
            "XF86AudioLowerVolume".action.spawn = [
              "wpctl"
              "set-volume"
              "@DEFAULT_AUDIO_SINK@"
              "5%-"
            ];
            "XF86AudioMute".action.spawn = [
              "wpctl"
              "set-mute"
              "@DEFAULT_AUDIO_SINK@"
              "toggle"
            ];
            "XF86MonBrightnessUp".action.spawn = [
              "brightnessctl"
              "s"
              "5%+"
            ];
            "XF86MonBrightnessDown".action.spawn = [
              "brightnessctl"
              "s"
              "5%-"
            ];

            "Print".action.spawn = [
              "sh"
              "-c"
              ''${lib.getExe pkgs.grim} -g "$(${lib.getExe pkgs.slurp})" - | ${lib.getExe pkgs.satty} -f - --action-on-enter save-to-clipboard''
            ];
          };
      };
    };
  };
}
