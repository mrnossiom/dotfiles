{ ... }:

{
  config = {
    virtualisation.docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };

    services.flatpak.enable = true;
  };
}
