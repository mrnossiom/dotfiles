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

  specialModuleArgs = pkgs: {
    # this flake
    inherit self;
    # local flake library
    llib = import ../. pkgs;
    # local packages set
    lpkgs = import ../../pkgs pkgs;
    # unstable nixpkgs set
    upkgs = import nixpkgs-unstable { inherit (pkgs) system config; };
    # indicates if system is darwin
    isDarwin = pkgs.stdenv.isDarwin;
  };

  createSystem = pkgs: modules: nixosSystem {
    inherit pkgs;
    modules = modules ++ [
      ../../nixos/fragments/default.nix
    ];
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
    inherit pkgs;
    modules = modules ++ [
      ../../home-manager/fragments/default.nix
      ../../home-manager/options.nix
    ];
    extraSpecialArgs = (specialModuleArgs pkgs) // { osConfig = null; };
  };

  # Darwin related
  darwin = {
    createSystem = pkgs: modules: darwinSystem {
      inherit pkgs;
      modules = modules ++ [
        ../../nixos/fragments/default.nix
      ];
      specialArgs = specialModuleArgs pkgs;
    };

    inherit system;
    user = import ./user.nix;
  };
}
