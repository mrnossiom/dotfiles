{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.local.fragment.sddm;
in

{
  options.local.fragment.sddm.enable = lib.mkEnableOption ''
    SDDM related
  '';

  config = lib.mkIf cfg.enable {
    services.displayManager.defaultSession = "niri";

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      theme = "where_is_my_sddm_theme";

      extraPackages = [
        pkgs.qt6Packages.qt5compat
      ];

      settings = {
        General = {
          DisplayServer = "wayland";
          GreeterEnvironment = "QT_SCREEN_SCALE_FACTORS=2";
          HideCursor = true;
        };
      };
    };

    environment.systemPackages = [
      (pkgs.where-is-my-sddm-theme.override {
        themeConfig.General = {
          passwordInputWidth = "0.8";
          passwordFontSize = "72";

          font = "sans-serif";
          helpFont = "sans-serif";
        };
      })
    ];

    environment.variables = {
      XDG_SESSION_TYPE = "wayland";
      XDG_CURRENT_DESKTOP = "Niri";
    };
  };
}
