{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

    flake-utils.url = "github:numtide/flake-utils";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, gitignore }: flake-utils.lib.eachDefaultSystem (system:
    let
      overlays = [ (import rust-overlay) ];
      pkgs = import nixpkgs { inherit system overlays; };
      rustToolchain = pkgs.pkgsBuildHost.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;

      libraries = [ ];

      nativeBuildInputs = with pkgs; [
        pkg-config
        rustToolchain
        rust-analyzer
        act
      ];
      buildInputs = [ ];
    in
    {
      formatter = pkgs.nixpkgs-fmt;

      packages = rec {
        default = app;
        app = pkgs.callPackage ./package.nix { inherit gitignore; };
      };
      apps = rec {
        default = app;
        app = flake-utils.lib.mkApp { drv = self.packages.${system}.app; };
      };

      devShells.default = pkgs.mkShell {
        inherit nativeBuildInputs buildInputs;

        RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath libraries;

        RUST_LOG = "";
      };
    }
  );
}
