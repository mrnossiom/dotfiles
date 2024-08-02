{ self
, lib
, ...
}:

with lib;

let
  inherit (self.inputs) nixpkgs-unstable nix-darwin;
  inherit (self.flake-lib) specialModuleArgs;

  inherit (nix-darwin.lib) darwinSystem;
in
rec {
  forAllSystems = genAttrs [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];

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
    specialArgs = specialModuleArgs pkgs;
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
