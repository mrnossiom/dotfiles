{ self, lib, ... }:

with lib;

let
  inherit (self.inputs) nixpkgs-unstable;
in
{
  # Makes
  # - flake accessible through `self`
  # - local flake library accessible through `llib`
  # - unstable nixpkgs set accessible through `upkgs`
  specialModuleArgs = pkgs: {
    inherit self;
    llib = import ../. pkgs;
    upkgs = import nixpkgs-unstable { inherit (pkgs) system config; };
  };

  createSystem = pkgs: modules: nixosSystem {
    inherit pkgs modules;
    specialArgs = self.flakeLib.specialModuleArgs pkgs;
  };

  system = hostName: profile: {
    imports = [
      ../../nixos/hardware/${hostName}.nix
      ../../nixos/profiles/${profile}.nix
    ];
    networking.hostName = hostName;
  };
  user = import ./user.nix;
  managedDiskLayout = import ./managedDiskLayout.nix;
}
