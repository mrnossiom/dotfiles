{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.local.fragment.sway;

  colors = config.lib.stylix.colors.withHashtag;
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.sway.config.menu =
      let
        tofi-drun = lib.getExe' pkgs.tofi "tofi-drun";
        swaymsg = lib.getExe' config.wayland.windowManager.sway.package "swaymsg";
        jq = lib.getExe pkgs.jq;
      in
      "${tofi-drun} --output `${swaymsg} -t get_outputs| ${jq} -r '.[] | select(.focused).name'` | xargs ${swaymsg} exec --";

    programs.tofi = {
      enable = true;
      settings = {
        anchor = "top";
        horizontal = true;
        height = 52;
        width = "100%";

        outline-width = 0;
        border-width = 0;

        min-input-width = 100;
        result-spacing = 30;

        padding-top = 12;
        padding-bottom = 12;
        padding-left = 20;
        padding-right = 20;

        prompt-text = " ";
        prompt-padding = 30;
        prompt-background-padding = "5, 10";
        prompt-background-corner-radius = 5;

        input-background-padding = "5, 10";
        input-background-corner-radius = 5;

        selection-color = lib.mkForce colors.base07;
        selection-match-color = colors.base0A;
        selection-background = lib.mkForce colors.base02;
        selection-background-padding = "5, 10";
        selection-background-corner-radius = 8;

        default-result-background = lib.mkForce colors.base01;
        default-result-background-corner-radius = 8;
        default-result-background-padding = "5, 10";

        clip-to-padding = false;
      };
    };
  };
}
