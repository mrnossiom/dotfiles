{ ... }@pkgs: {
  createSystem = hostName: config: {
    imports = [
      ../../nixos/hardware/${hostName}.nix
      config
    ];

    networking.hostName = hostName;
  };

  createUser = import ./createUser.nix;
}
