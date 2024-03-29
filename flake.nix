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

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # TODO: replace with a custom module, this just acts as a module definition
    nix-colors.url = "github:misterio77/nix-colors";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    git-leave.url = "github:mrnossiom/git-leave";
    git-leave.inputs.nixpkgs.follows = "nixpkgs";

    mind.url = "github:sayanarijit/mind";
    mind.inputs.nixpkgs.follows = "nixpkgs";

    radicle.url = "git+https://seed.radicle.xyz/z3gqcJUoA1n9HaHKufZs5FCSGazv5";
    radicle.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... }:
    let
      inherit (self) outputs;
      inherit (nixpkgs.lib) genAttrs;

      forAllSystems = genAttrs [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      flakeLib = import ./lib/flake (nixpkgs // { inherit self; });

      # This sould be the only constructed nixpkgs instance in this flake
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
      templates = import ./templates;

      # Custom exports
      inherit flakeLib;
      lib = forAllSystems (system: import ./lib pkgs.${system});

      nixosConfigurations = with flakeLib; {
        "neo-wiro-laptop" = createSystem pkgs."x86_64-linux" [
          (system "neo-wiro-laptop" "laptop")
          (managedDiskLayout "luks-btrfs" { device = "nvme0n1"; swapSize = 12; })
          (user "milomoisson" { description = "Milo Moisson"; profile = "desktop"; })
        ];

        "archaic-wiro-laptop" = createSystem pkgs."x86_64-linux" [
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
