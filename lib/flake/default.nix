{ self
, lib
, ...
}:

with lib;

let
  inherit (self.inputs) home-manager nixpkgs-unstable nix-darwin;

  inherit (nix-darwin.lib) darwinSystem;
  inherit (home-manager.lib) homeManagerConfiguration;
in
rec {
  forAllSystems = genAttrs [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];

  # - `self`: flake
  # - `llib`: local flake library
  # - `lpkgs`: local packages set
  # - `upkgs`: unstable nixpkgs set
  # - `isDarwin`: indicates if system is darwin
  specialModuleArgs = pkgs: {
    inherit self;
    llib = import ../. pkgs;
    lpkgs = import ../../pkgs pkgs;
    upkgs = import nixpkgs-unstable { inherit (pkgs) system config; };
    isDarwin = pkgs.stdenv.isDarwin;
  };

  createSystem = pkgs: modules: nixosSystem {
    inherit pkgs modules;
    specialArgs = specialModuleArgs pkgs;
  };

  # `createSystem` modules
  system = hostName: profile: {
    imports = [
      ../../nixos/hardware/${hostName}.nix
      ../../nixos/profiles/${profile}.nix
    ];
    networking.hostName = hostName;
  };
  user = import ./user.nix;
  managedDiskLayout = import ./managedDiskLayout.nix;

  createHomeManager = pkgs: modules: homeManagerConfiguration {
    inherit pkgs modules;
    extraSpecialArgs = (specialModuleArgs pkgs) // { osConfig = null; };
  };

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
