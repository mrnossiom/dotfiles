let
  isDarwin = false;
in
{
  flake.modules.nixos.fonts = { lib, pkgs, ... }: {
    config = {
      fonts = {
        packages = with pkgs; [
          font-awesome
          inter
          nerd-fonts.jetbrains-mono
          merriweather
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-color-emoji
        ];
      }
      // lib.optionalAttrs (!isDarwin) {
        fontconfig = {
          defaultFonts = {
            sansSerif = [
              "Inter"
              "Noto Sans"
              "Noto Sans Japanese"
              "Noto Sans Korean"
              "Noto Sans Chinese"
            ];
            serif = [ "Merriweather" ];
            monospace = [
              "JetBrainsMono Nerd Font"
              "Noto Sans Mono"
            ];
            emoji = [ "Noto Color Emoji" ];
          };
        };
      };
    };
  };
}
