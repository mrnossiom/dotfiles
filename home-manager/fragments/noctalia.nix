{
  self,
  config,
  lib,
  upkgs,
  ...
}:

let
  inherit (self.inputs) noctalia;

  cfg = config.local.fragment.noctalia;
in

{
  options.local.fragment.noctalia.enable = lib.mkEnableOption ''
    Noctalia related
  '';

  imports = [ noctalia.homeModules.default ];

  config = lib.mkIf cfg.enable {
    programs.noctalia-shell = {
      enable = true;
      package = upkgs.noctalia-shell;

      settings = {
        colorSchemes.predefinedScheme = "Monochrome";

        general = {
          # avatarImage = "${config.home.homeDirectory}/Pictures/0000-profile-picture/";
          radiusRatio = 0.2;
        };

        # ../../assets/wallpaper-binary-cloud.png

        location = {
          monthBeforeDay = true;
          name = "Paris, France";
        };

        bar = {
          density = "compact";
          position = "top";
          showCapsule = false;

          widgets = {
            left = [
              { id = "ControlCenter"; }
              { id = "Network"; }
              { id = "Bluetooth"; }
            ];

            center = [
              {
                hideUnoccupied = false;
                id = "Workspace";
                labelMode = "none";
              }
            ];

            right = [
              {
                id = "Battery";
                alwaysShowPercentage = false;
                warningThreshold = 30;
              }
              {
                id = "Clock";
                formatHorizontal = "HH:mm";
                formatVertical = "HH mm";
                useMonospacedFont = true;
                usePrimaryColor = true;
              }
              {
                id = "Tray";
              }
            ];
          };
        };
      };
    };
  };
}
