{ config
, lib
, pkgs
, ...
}:

with lib;

{
  options = { };

  config = {
    wayland.windowManager.sway.config.menu = "${getExe' pkgs.tofi "tofi-drun"} --font ${pkgs.inter}/share/fonts/opentype/Inter-Regular.otf | xargs ${getExe' pkgs.sway "swaymsg"} exec --";

    xdg.configFile."tofi/config".text = with config.colorScheme.colors;
      lib.generators.toKeyValue { } {
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
