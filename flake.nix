{
  description = "NixOS and Home Manager configuration for Milo's laptops";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    unixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager.url = "github:nix-community/home-manager?ref=release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:nix-darwin/nix-darwin?ref=nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:nix-community/stylix?ref=release-25.11";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    ## Miscellaneous

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.home-manager.follows = "home-manager";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    lanzaboote.url = "github:nix-community/lanzaboote";
    lanzaboote.inputs.nixpkgs.follows = "unixpkgs";

    srvos.url = "github:nix-community/srvos";
    srvos.inputs.nixpkgs.follows = "nixpkgs";

    ## Packages

    git-leave.url = "github:mrnossiom/git-leave";
    git-leave.inputs.nixpkgs.follows = "nixpkgs";

    hypixel-bank-tracker.url = "github:pixilie/hypixel-bank-tracker";
    hypixel-bank-tracker.inputs.nixpkgs.follows = "nixpkgs";

    nix-alien.url = "github:thiagokokada/nix-alien";
    nix-alien.inputs.nixpkgs.follows = "nixpkgs";

    tangled.url = "git+https://tangled.org/tangled.org/core";
    tangled.inputs.nixpkgs.follows = "unixpkgs";

    wakatime-ls.url = "github:mrnossiom/wakatime-ls";
    wakatime-ls.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "unixpkgs";
    zen-browser.inputs.home-manager.follows = "home-manager";
  };

  outputs = { self, nixpkgs, ... }:
    let
      inherit (self) outputs;
      inherit (flake-lib) forAllSystems;

      flake-lib = import ./lib/flake (nixpkgs // { inherit self; });

      # This should be the only constructed nixpkgs instances in this flake
      allPkgs = forAllSystems (system: (import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = import ./lib/unfree.nix { lib = nixpkgs.lib; };
        overlays = [ outputs.overlays.all ];
      }));

      forAllPkgs = func: forAllSystems (system: func allPkgs.${system});
    in
    {
      formatter = forAllPkgs (pkgs: pkgs.nixpkgs-fmt);

      inherit flake-lib; # Nonstandard
      lib = forAllPkgs (import ./lib);
      templates = import ./templates;

      apps = forAllPkgs (import ./apps { pkgs-per-system = allPkgs; });
      devShells = forAllPkgs (import ./shells.nix);
      overlays = import ./overlays (nixpkgs // { inherit self; });
      packages = forAllPkgs (import ./pkgs);

      homeManagerModules = import ./modules/home-manager;
      nixosModules = import ./modules/nixos;

      # `nixos`, `home-manager` and `nix-darwin` configs are generic over `pkgs` and placed in `configurations.nix`
      # `legacyPackages` tree structure is not checked by `nix flake check` but picked up by all rebuild tools
      legacyPackages = forAllPkgs (import ./configurations.nix flake-lib);
    };
}
