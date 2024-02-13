{ lib
, config
, pkgs
, ...
}:

with lib;

{
  config = {
    virtualisation.docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };

    virtualisation.waydroid.enable = true;

    services.flatpak.enable = true;
  };
}
