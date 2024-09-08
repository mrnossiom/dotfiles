{ lib
, pkgs
, config
, isDarwin
, ...
}:

let
  cfg = config.local.fragment.fonts;
in
{
  options.local.fragment.fonts.enable = lib.mkEnableOption ''
    Fonts related
  '';

  config = lib.mkIf cfg.enable {
    fonts = {
      packages = with pkgs; [
        (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
        inter
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        font-awesome
      ];
    } // lib.optionalAttrs (!isDarwin) {
      fontconfig = {
        defaultFonts = rec {
          monospace = [ "JetBrainsMono Nerd Font" "Noto Sans Mono" ];
          sansSerif = [ "Inter" "Noto Sans" "Noto Sans Japanese" "Noto Sans Korean" "Noto Sans Chinese" ];
          # Serif is ugly
          serif = sansSerif;
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
  };
}
