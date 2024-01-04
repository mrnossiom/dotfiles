{
  description = "NixOS and Home Manager configuration for Milo's laptops";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors.url = "github:misterio77/nix-colors";

    nixos-hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, ... }:
    let
      inherit (self) inputs outputs;
      inherit (nixpkgs.lib) nixosSystem genAttrs;
      inherit (home-manager) homeManagerConfiguration;

      forAllSystems = genAttrs [ "aarch64-linux" "i686-linux" "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];
      flake-lib = import ./lib/flake (nixpkgs // { inherit self; });

      pkgs = forAllSystems (system: (import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = import ./lib/unfree.nix;
        overlays = [ outputs.overlays.all ];
      }) // { inherit self; });
    in
    {
      formatter = forAllSystems (system: pkgs.${system}.nixpkgs-fmt);

      packages = forAllSystems (system: import ./pkgs pkgs.${system});
      apps = forAllSystems (system: import ./apps pkgs.${system});

      overlays = import ./overlays (nixpkgs // { inherit self; });
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;

      nixosConfigurations = {
        "neo-wiro-laptop" = flake-lib.createSystem [
          (flake-lib.system "neo-wiro-laptop" ./nixos/profiles/laptop.nix)
          (flake-lib.managedDiskLayout "nvme0n1" ./nixos/layout/luks-btrfs.nix)
          (flake-lib.user "milomoisson" {
            description = "Milo Moisson";
            config = ./home-manager/profiles/desktop.nix;
          })
        ];

        "archaic-wiro-laptop" = flake-lib.createSystem [
          (flake-lib.system "archaic-wiro-laptop" ./nixos/profiles/laptop.nix)
          (flake-lib.user "milomoisson" {
            description = "Milo Moisson";
            config = ./home-manager/profiles/desktop.nix;
          })
        ];
      };

      # In non-NixOS contexts, you can still home manager to manage dotfiles.
      # Else, configuration is loaded by the HM NixOS module which create system generations and free rollbacks.
      homeConfigurations = {
        milomoisson = homeManagerConfiguration {
          pkgs = nixpkgs.pkgs;
          extraSpecialArgs = { inherit self; };
          modules = [ ./home-manager/profiles/desktop.nix ];
        };
      };
    };
}
