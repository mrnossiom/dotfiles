{ config
, lib
, pkgs

, isDarwin
, ...
}:

let
  cfg = config.local.fragment.fonts;

  jetbrains-mono-nerd = (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; });
in
{
  options.local.fragment.fonts.enable = lib.mkEnableOption ''
    Fonts related
  '';

  config = lib.mkIf cfg.enable {
    fonts = {
      packages = with pkgs; [
        font-awesome
        inter
        jetbrains-mono-nerd
        merriweather
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
      ];
    } // lib.optionalAttrs (!isDarwin) {
      fontconfig = {
        defaultFonts = {
          sansSerif = [ "Inter" "Noto Sans" "Noto Sans Japanese" "Noto Sans Korean" "Noto Sans Chinese" ];
          serif = [ "Merriweather" ];
          monospace = [ "JetBrainsMono Nerd Font" "Noto Sans Mono" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
  };
}
