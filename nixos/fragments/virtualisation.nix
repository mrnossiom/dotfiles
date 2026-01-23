{
  config,
  lib,
  ...
}:

let
  cfg = config.local.fragment.security;
in
{
  options.local.fragment.virtualisation.enable = lib.mkEnableOption ''
    Virtualisation related
    - Docker
  '';

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;

      rootless = {
        enable = true;
        setSocketVariable = true;
      };

      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
  };
}
