{ self
, config
, lib
, pkgs
, ...
}:

let
  inherit (self.inputs) stylix;

  cfg = config.local.fragment.stylix;
in
{
  imports = [
    stylix.homeModules.stylix
    # issues a warning because we use `useGlobalPkgs`
    { config.stylix.overlays.enable = false; }
  ];

  options.local.fragment.stylix.enable = lib.mkEnableOption ''
    Stylix related
  '';

  config = lib.mkIf cfg.enable {
    # TODO: take a lot of build time
    # specialisation.light.configuration = {
    #   stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/one-light.yaml";
    # };

    stylix = {
      enable = true;
      base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/onedark-dark.yaml";

      image = ../../assets/wallpaper-binary-cloud.png;

      fonts = {
        sansSerif = { package = pkgs.inter; name = "Inter"; };
        serif = { package = pkgs.merriweather; name = "Merriweather"; };
        monospace = { package = pkgs.nerd-fonts.jetbrains-mono; name = "JetBrainsMono Nerd Font"; };

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
}
