{ config
, lib

, isDarwin
, ...
}:

let
  cfg = config.local.fragment.foot;
in
{
  options.local.fragment.foot.enable = lib.mkEnableOption ''
    Foot terminal related
  '';

  config = lib.mkIf cfg.enable {
    assertions = [
      { assertion = !isDarwin; message = "this is a non-darwin fragment"; }
    ];

    home.sessionVariables.TERMINAL = lib.getExe config.programs.foot.package;

    programs.foot = {
      enable = true;

      # TODO: promising but too buggy
      # server.enable = true;
    };
  };
}


