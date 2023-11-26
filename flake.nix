{
  description = "NixOS and Home Manager configuration for Milo's laptops";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
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

    hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = { self, nixpkgs, home-manager, agenix, nix-index-database, disko, nix-colors, ... }@inputs:
    let
      inherit (self) outputs;
      systems = [ "aarch64-linux" "i686-linux" "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      baseModules = [
        ./nixos/configuration.nix
        disko.nixosModules.disko

        agenix.nixosModules.default
        ./secrets
        { age.identityPaths = [ "/home/milomoisson/.ssh/id_ed25519" ]; }

      ];
    in
    {
      packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);

      overlays = import ./overlays { inherit inputs; };
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;

      nixosConfigurations = {
        "neo-wiro-laptop" = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = baseModules ++ [
            # TODO: copy when generated
            # ./nixos/hardware/neo.nix
          ];
        };

        "archaic-wiro-laptop" = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = baseModules ++ [
            ./nixos/hardware/archaic.nix
          ];
        };
      };

      homeConfigurations = {
        "milomoisson" = home-manager.lib.homeManagerConfiguration {
          # Home-manager requires 'pkgs' instance
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            ./home-manager

            # Agenix secrets manager
            agenix.homeManagerModules.default
            # TODO: dont hardcode system
            { home.packages = [ agenix.packages.x86_64-linux.default ]; }

            # Setup `comma`, which allow to easily run command that are not present on the system
            nix-index-database.hmModules.nix-index

            # Nix colors
            nix-colors.homeManagerModules.default
            { colorScheme = nix-colors.colorSchemes.onedark; }

            ./secrets

            # Unstable module taken from master branch
            # outputs.homeManagerModules.darkman
          ];
        };
      };
    };
}
