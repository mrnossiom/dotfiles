{ self, lib, ... }@pkgs:

with lib;

{
  createSystem = modules: nixosSystem {
    specialArgs = { inherit self; };
    inherit modules;
  };

  system = hostName: profile: {
    imports = [ profile ];
    networking.hostName = hostName;
  };
  user = import ./user.nix;
  managedDiskLayout = import ./managedDiskLayout.nix;
}
