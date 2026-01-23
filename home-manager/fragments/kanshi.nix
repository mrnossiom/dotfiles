{
  config,
  lib,

  isDarwin,
  ...
}:

let
  cfg = config.local.fragment.kanshi;
in
{
  options.local.fragment.kanshi.enable = lib.mkEnableOption ''
    Kanshi related
  '';

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !isDarwin;
        message = "this is a non-darwin fragment";
      }
    ];

    services.kanshi = {
      enable = true;

      settings = [
        {
          output = {
            criteria = "eDP-1";
            scale = 2.0;
          };
        }

        {
          profile.name = "undocked";
          profile.outputs = [
            { criteria = "eDP-1"; }
          ];
        }

        {
          profile.name = "eizo-dock";
          # position external screen centered above
          profile.outputs = [
            {
              criteria = "Eizo Nanao Corporation CG222W 29804118";
              position = "0,0";
            }
            {
              criteria = "eDP-1";
              position = "120,1050";
            }
          ];
        }

        {
          profile.name = "hdmi-default";
          # position external screen right
          profile.outputs = [
            {
              criteria = "eDP-1";
              position = "0,0";
            }
            {
              criteria = "HDMI";
              position = "1440,0";
            }
          ];
        }
      ];
    };
  };
}
