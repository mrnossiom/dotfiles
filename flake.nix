{
  description = "NixOS and Home Manager configuration for Milo's laptops";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.home-manager.follows = "home-manager";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # TODO: replace with a custom module, this just acts as a module definition
    nix-colors.url = "github:misterio77/nix-colors";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    # ——— Packages
    git-leave.url = "github:mrnossiom/git-leave";
    git-leave.inputs.nixpkgs.follows = "nixpkgs";

    helix.url = "github:helix-editor/helix";
    helix.inputs.nixpkgs.follows = "nixpkgs";

    radicle.url = "git+https://seed.radicle.xyz/z3gqcJUoA1n9HaHKufZs5FCSGazv5";
    radicle.inputs.nixpkgs.follows = "nixpkgs";

    wakatime-lsp.url = "github:mrnossiom/wakatime-lsp";
    wakatime-lsp.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... }:
    let
      inherit (self) outputs;
      inherit (flake-lib) forAllSystems;

      flake-lib = import ./lib/flake (nixpkgs // { inherit self; });
      keys = import ./secrets/keys.nix;

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

      packages = forAllPkgs (import ./pkgs);
      apps = forAllPkgs (import ./apps { inherit forAllPkgs; });
      devShells = forAllPkgs (import ./shells.nix);

      overlays = import ./overlays (nixpkgs // { inherit self; });
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;
      templates = import ./templates;

      # Custom exports
      inherit flake-lib;
      lib = forAllPkgs (import ./lib);

      nixosConfigurations = with flake-lib; {
        # Desktops
        "neo-wiro-laptop" = createSystem pkgs."x86_64-linux" [
          (system "neo-wiro-laptop" "laptop")
          (managedDiskLayout "luks-btrfs" { device = "nvme0n1"; swapSize = 12; })
          (user "milomoisson" { description = "Milo Moisson"; profile = "desktop"; keys = keys.users; })
        ];

        "archaic-wiro-laptop" = createSystem pkgs."x86_64-linux" [
          (system "archaic-wiro-laptop" "laptop")
          (user "milomoisson" { description = "Milo Moisson"; profile = "desktop"; keys = keys.users; })
        ];

        # # Servers
        # "weird-row-server" = createSystem pkgs."x86_64-linux" [
        #   (system "weird-row-server" "server")
        #   (user "milomoisson" { description = "Milo Moisson"; profile = "minimal"; keys = keys.users; })
        # ];
      };

      # I bundle my Home Manager config via the NixOS modules which create system generations and give free rollbacks.
      # However, in non-NixOS contexts, you can still use Home Manager to manage dotfiles using this template.
      homeConfigurations = with flake-lib; {
        # TODO: should not be system specific
        "lightweight" = createHomeManager pkgs."x86_64-linux" [
          ./home-manager/profiles/lightweight.nix
        ];
      };

      darwinConfigurations = with flake-lib.darwin; {
        "apple-wiro-laptop" = createSystem pkgs."aarch64-darwin" [
          (system "apple-wiro-laptop" "macintosh")
          (user "milomoisson" { description = "Milo Moisson"; profile = "macintosh"; keys = keys.users; })
        ];
      };
    };
}
