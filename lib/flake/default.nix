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

  # - `self`: flake
  # - `llib`: local flake library
  # - `upkgs`: unstable nixpkgs set
  # - `isDarwin`: indicates if system is darwin
  specialModuleArgs = pkgs: {
    inherit self;
    llib = import ../. pkgs;
    upkgs = import nixpkgs-unstable { inherit (pkgs) system config; };
    isDarwin = pkgs.stdenv.isDarwin;
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

  # Darwin related
  darwin = {
    createSystem = pkgs: modules: darwinSystem {
      inherit pkgs modules;
      specialArgs = specialModuleArgs pkgs;
    };

    inherit system;
    user = import ./user.nix;
  };
}
