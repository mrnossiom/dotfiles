{
  description = "NixOS and Home Manager configuration for Milo's laptops";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.home-manager.follows = "home-manager";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    srvos.url = "github:nix-community/srvos";
    # srvos.inputs.nixpkgs.follows = "srvos/nixpkgs";
    srvos.inputs.nixpkgs.follows = "nixpkgs";

    # ——— Packages
    git-leave.url = "github:mrnossiom/git-leave";
    git-leave.inputs.nixpkgs.follows = "nixpkgs";

    helix.url = "github:helix-editor/helix";
    helix.inputs.nixpkgs.follows = "nixpkgs-unstable";

    jujutsu.url = "github:jj-vcs/jj";
    jujutsu.inputs.nixpkgs.follows = "nixpkgs-unstable";

    nixocaine.url = "https://git.madhouse-project.org/iocaine/nixocaine/archive/main.tar.gz";
    nixocaine.inputs.nixpkgs.follows = "nixpkgs";

    tangled.url = "git+https://tangled.sh/@tangled.sh/core";
    tangled.inputs.nixpkgs.follows = "nixpkgs";

    wakatime-ls.url = "github:mrnossiom/wakatime-ls";
    wakatime-ls.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... }:
    let
      inherit (self) outputs;
      inherit (flake-lib) forAllSystems;

      flake-lib = import ./lib/flake (nixpkgs // { inherit self; });

      forAllPkgs = func: forAllSystems (system: func pkgs.${system});

      # This should be the only constructed nixpkgs instances in this flake
      pkgs = forAllSystems (system: (import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = import ./lib/unfree.nix { lib = nixpkgs.lib; };
        overlays = [ outputs.overlays.all ];
      }));
    in
    {
      formatter = forAllPkgs (pkgs: pkgs.nixpkgs-fmt);

      inherit flake-lib; # Nonstandard
      lib = forAllPkgs (import ./lib);
      templates = import ./templates;

      apps = forAllPkgs (import ./apps { inherit forAllPkgs; });
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
