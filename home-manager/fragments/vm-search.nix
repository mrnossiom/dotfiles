{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.local.fragment.vm;

  theme = config.colorScheme.palette;
  keyValueFormat = lib.generators.toKeyValue { };
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.sway.config.menu =
      let
        tofi-drun = lib.getExe' pkgs.tofi "tofi-drun";
        swaymsg = lib.getExe' pkgs.sway "swaymsg";

        jetbrains-nerd-font = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
        jetbrains-nerd-font-regular = "${jetbrains-nerd-font}/share/fonts/truetype/JetBrainsMonoNerdFont-Regular.ttf";
      in
      "${tofi-drun} --font ${jetbrains-nerd-font-regular} | xargs ${swaymsg} exec --";

    xdg.configFile."tofi/config".text = keyValueFormat {
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

      text-color = "#${theme.base06}";
      background-color = "#${theme.base00}";

      prompt-text = " ";
      prompt-padding = 30;
      prompt-background = "#${theme.base01}";
      prompt-background-padding = "5, 10";
      prompt-background-corner-radius = 5;

      input-color = "#${theme.base07}";
      input-background = "#${theme.base01}";
      input-background-padding = "5, 10";
      input-background-corner-radius = 5;

      selection-color = "#${theme.base0E}";
      selection-background = "#${theme.base01}";
      selection-background-padding = "5, 10";
      selection-background-corner-radius = 8;
      selection-match-color = "#${theme.base08}";

      clip-to-padding = false;
    };
  };
}
