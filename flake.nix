{
  description = "NixOS and Home Manager configuration for Milo's laptops";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.xz";
    unixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";

    home-manager.url = "github:nix-community/home-manager?ref=release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:nix-darwin/nix-darwin?ref=nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:nix-community/stylix?ref=release-26.05";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    ## Miscellaneous

    flake-parts.url = "github:hercules-ci/flake-parts";

    import-tree.url = "github:vic/import-tree";

    agenix.url = "github:ryantm/agenix?ref=0.18.0";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.home-manager.follows = "home-manager";

    disko.url = "github:nix-community/disko?ref=v1.13.0";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote.url = "github:nix-community/lanzaboote?ref=v1.2.0";
    lanzaboote.inputs.nixpkgs.follows = "unixpkgs";
    lanzaboote.inputs.rust-overlay.follows = "rust-overlay";

    srvos.url = "github:nix-community/srvos";
    srvos.inputs.nixpkgs.follows = "nixpkgs";

    ## Libraries

    net.url = "github:0xCCF4/nix-net-lib";
    net.inputs.nixpkgs.follows = "unixpkgs";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "unixpkgs";

    ## Packages

    git-leave.url = "github:mrnossiom/git-leave";
    git-leave.inputs.nixpkgs.follows = "nixpkgs";
    git-leave.inputs.rust-overlay.follows = "rust-overlay";

    git-pages.url = "git+https://codeberg.org/git-pages/git-pages";
    git-pages.inputs.nixpkgs.follows = "nixpkgs";

    helix.url = "github:helix-editor/helix";
    helix.inputs.nixpkgs.follows = "unixpkgs";
    helix.inputs.rust-overlay.follows = "rust-overlay";

    hypixel-bank-tracker.url = "github:pixilie/hypixel-bank-tracker";
    hypixel-bank-tracker.inputs.nixpkgs.follows = "nixpkgs";
    hypixel-bank-tracker.inputs.rust-overlay.follows = "rust-overlay";

    nix-alien.url = "github:thiagokokada/nix-alien";
    nix-alien.inputs.nixpkgs.follows = "nixpkgs";

    tangled.url = "git+https://tangled.org/tangled.org/core?ref=v1.16.1-alpha";
    tangled.inputs.nixpkgs.follows = "unixpkgs";
    # remove useless tangled inputs
    tangled.inputs = {
      actor-typeahead-src.follows = "";
      fenix.follows = "";
      htmx-src.follows = "";
      htmx-ws-src.follows = "";
      ibm-plex-mono-src.follows = "";
      inter-fonts-src.follows = "";
      lucide-src.follows = "";
      mermaid-src.follows = "";
    };

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "unixpkgs";
    zen-browser.inputs.home-manager.follows = "home-manager";

    ## Files

    wolf-alabaster-helix.url = "github:wolf/alabaster-for-helix";
    wolf-alabaster-helix.flake = false;
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        systems = [
          "aarch64-darwin"
          "aarch64-linux"
          "x86_64-linux"
        ];
        imports = [
          inputs.home-manager.flakeModules.home-manager

          (inputs.import-tree ./src)
        ];
        flake = { };
        perSystem = { pkgs, ... }: {
          formatter = pkgs.nixfmt-tree;
        };
      }
    );
}
