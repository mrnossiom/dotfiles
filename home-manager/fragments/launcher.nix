{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.local.fragment.sway;
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.sway.config.menu =
      let
        tofi-drun = lib.getExe' pkgs.tofi "tofi-drun";
        swaymsg = lib.getExe' config.wayland.windowManager.sway.package "swaymsg";

        jetbrains-nerd-font-regular = "${pkgs.nerd-fonts.jetbrains-mono}/share/fonts/truetype/JetBrainsMonoNerdFont-Regular.ttf";
      in
      "${tofi-drun} --font ${jetbrains-nerd-font-regular} | xargs ${swaymsg} exec --";

    programs.tofi = {
      enable = true;
      settings = {
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

        prompt-text = " ";
        prompt-padding = 30;
        prompt-background-padding = "5, 10";
        prompt-background-corner-radius = 5;

        input-background-padding = "5, 10";
        input-background-corner-radius = 5;

        selection-background-padding = "5, 10";
        selection-background-corner-radius = 8;

        clip-to-padding = false;
      };
    };
  };
}
