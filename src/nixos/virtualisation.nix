{
  flake.modules.nixos.virtualisation = { ... }: {
    config = {
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

      virtualisation.waydroid.enable = true;
    };
  };
}
