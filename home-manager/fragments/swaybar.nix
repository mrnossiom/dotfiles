{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.local.fragment.swaybar;

  integrated-keyboard-id = "1:1:AT_Translated_Set_2_keyboard";
  integrated-keyboard-id-bis = "1:1:kanata";

  swaymsg = lib.getExe' pkgs.sway "swaymsg";
in
{
  options.local.fragment.swaybar.enable = lib.mkEnableOption ''
    Swaybar related
  '';

  config = lib.mkIf cfg.enable {
    programs.i3status-rust = {
      enable = true;

      bars.default = {
        theme = "modern";
        icons = "awesome6";

        settings.icon_format = " <span font_family='FontAwesome6'>{icon}</span> ";

        blocks = [
          {
            block = "custom";
            command = ''
              echo 󰌌  $(swaymsg --raw --type get_inputs \
                | jq --raw-output '
                  .[]
                  | select(.identifier=="${integrated-keyboard-id}")
                  | .libinput.send_events')
            '';
            click = [{
              button = "left";
              cmd = ''
                ${swaymsg} input ${integrated-keyboard-id} events toggle;
                ${swaymsg} input ${integrated-keyboard-id-bis} events toggle
              '';
              update = true;
            }];
            interval = "once";
          }

          {
            block = "custom";
            command = "echo  $(${lib.getExe' pkgs.mako "makoctl"} mode)";
            click = [{
              button = "left";
              # Toggle DND mode
              cmd = "${lib.getExe' pkgs.mako "makoctl"} mode -t dnd";
              update = true;
            }];
            interval = "once";
          }

          { block = "music"; }
          {
            format = " 󰌌  $variant";
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

    wayland.windowManager.sway.config.bars = [
      ({
        statusCommand = "${lib.getExe pkgs.i3status-rust} ${config.home.homeDirectory}/${config.xdg.configFile."i3status-rust/config-default.toml".target}";

        hiddenState = "hide";
        mode = "hide";

        # TODO: fix color theme on the bar
        # TODO: would be nice to have rounded corners and padding when appearing

        extraConfig = "icon_theme Papirus";
      } // config.stylix.targets.sway.exportedBarConfig)
    ];
  };
}
