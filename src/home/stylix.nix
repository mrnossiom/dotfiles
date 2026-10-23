{ inputs, ... }:
{
  flake.modules.homeManager.stylix = { lib, pkgs, ... }: {
    imports = [
      inputs.stylix.homeModules.stylix
      # issues a warning because we use `useGlobalPkgs`
      { config.stylix.overlays.enable = false; }
    ];

    config = {
      # TODO: take a lot of build time
      # specialisation.light.configuration = {
      #   stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/one-light.yaml";
      # };

      stylix = {
        enable = true;
        autoEnable = false;

        targets.mako.enable = true;
        targets.sway.enable = true;
        targets.swaylock.enable = true;
        targets.tofi.enable = true;
        targets.waybar.enable = true;

        base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/onedark-dark.yaml";

        image = ../../assets/wallpaper-binary-cloud.png;

        fonts = {
          sansSerif = {
            package = pkgs.inter;
            name = "Inter";
          };
          serif = {
            package = pkgs.merriweather;
            name = "Merriweather";
          };
          monospace = {
            package = pkgs.nerd-fonts.jetbrains-mono;
            name = "JetBrainsMono Nerd Font";
          };

          sizes = {
            applications = 12;
            terminal = 10;

            desktop = 12;
            popups = 14;
          };
        };

        opacity = {
          popups = 0.8;
        };

        cursor = {
          name = "Bibata-Modern-Ice";
          package = pkgs.bibata-cursors;
          size = 24;
        };

        icons = {
          enable = true;
          package = pkgs.papirus-icon-theme;
          light = "Papirus-Light";
          dark = "Papirus-Dark";
        };
      };
    };
  };
}
