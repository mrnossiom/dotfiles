{
  description = "NixOS and Home Manager configuration for Milo's laptops";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.home-manager.follows = "home-manager";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nix-colors.url = "github:misterio77/nix-colors";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    git-leave.url = "github:mrnossiom/git-leave";
    git-leave.inputs.nixpkgs.follows = "nixpkgs";

    mind.url = "github:sayanarijit/mind";
    mind.inputs.nixpkgs.follows = "nixpkgs";

    radicle.url = "git+https://seed.radicle.xyz/z3gqcJUoA1n9HaHKufZs5FCSGazv5";
    radicle.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixos-hardware, ... }:
    let
      inherit (self) inputs outputs;
      inherit (nixpkgs.lib) nixosSystem genAttrs;

      forAllSystems = genAttrs [ "aarch64-linux" "i686-linux" "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];
      flakeLib = import ./lib/flake (nixpkgs // { inherit self; });

      pkgs = forAllSystems (system: (import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = import ./lib/unfree.nix;
        overlays = [ outputs.overlays.all ];
      }));
    in
    {
      formatter = forAllSystems (system: pkgs.${system}.nixpkgs-fmt);

      packages = forAllSystems (system: import ./pkgs pkgs.${system});
      apps = forAllSystems (system: import ./apps pkgs.${system});
      devShells = forAllSystems (system: import ./shells.nix pkgs.${system});

      overlays = import ./overlays (nixpkgs // { inherit self; });
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;

      nixosConfigurations = with flakeLib; {
        "neo-wiro-laptop" = createSystem [
          (system "neo-wiro-laptop" "laptop")
          (managedDiskLayout "luks-btrfs" { device = "nvme0n1"; swapSize = 12; })
          (user "milomoisson" { description = "Milo Moisson"; profile = "desktop"; })
        ];

        "archaic-wiro-laptop" = createSystem [
          (system "archaic-wiro-laptop" "laptop")
          (user "milomoisson" { description = "Milo Moisson"; profile = "desktop"; })
        ];
      };

      # I bundle my Home Manager config via the NixOS modules which create system generations and give free rollbacks.
      # However, in non-NixOS contexts, you can still use Home Manager to manage dotfiles using this template.
      homeConfigurations = {
        # "<username>@<hostname>" = homeManagerConfiguration {
        #   pkgs = pkgs."<system>";
        #   extraSpecialArgs = { inherit self; osConfig = null; };
        #   modules = [ ./home-manager/profiles/desktop.nix ];
        # };
      };
    };
}
