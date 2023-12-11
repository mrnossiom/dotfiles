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

  outputs = { self, nixpkgs, home-manager, agenix, nix-index-database, disko, nix-colors, nixos-hardware, ... }@inputs:
    let
      inherit (self) outputs;

      systems = [ "aarch64-linux" "i686-linux" "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # Local flake helpers
      lfh = import ./lib/flake nixpkgs;
    in
    {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);

      packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      apps = forAllSystems (system: import ./apps (nixpkgs.legacyPackages.${system}
        // { inherit (nixpkgs.lib) nixosSystem; inherit system; }));

      overlays = import ./overlays { inherit inputs; };
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;

      nixosConfigurations = {
        "neo-wiro-laptop" = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            (lfh.createSystem "neo-wiro-laptop" ./nixos/profiles/laptop.nix)
            (lfh.createUser "milomoisson" {
              description = "Milo Moisson";
              config = ./home-manager/profiles/desktop.nix;
            })
          ];
        };

        "archaic-wiro-laptop" = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            (lfh.createSystem "archaic-wiro-laptop" ./nixos/profiles/laptop.nix)
            (lfh.createUser "milomoisson" {
              description = "Milo Moisson";
              config = ./home-manager/profiles/desktop.nix;
            })
          ];
        };
      };

      # In non-NixOS contexts, you can still home manager to manage dotfiles.
      # Else, configuration is loaded by the HM NixOS module which create system generations and free rollbacks.
      homeConfigurations = {
        "milomoisson" = home-manager.lib.homeManagerConfiguration {
          # Home-manager requires 'pkgs' instance
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./home-manager/profiles/desktop.nix ];
        };
      };
    };
}
