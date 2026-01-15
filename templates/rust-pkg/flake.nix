{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

    gitignore.url = "github:hercules-ci/gitignore.nix";
    gitignore.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, rust-overlay, gitignore }:
    let
      inherit (nixpkgs.lib) genAttrs getExe;

      forAllSystems = genAttrs [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forAllPkgs = function: forAllSystems (system: function pkgs.${system});

      mkApp = (program: { type = "app"; inherit program; });

      pkgs = forAllSystems (system: (import nixpkgs {
        inherit system;
        overlays = [ (import rust-overlay) ];
      }));
    in
    {
      formatter = forAllPkgs (pkgs: pkgs.nixpkgs-fmt);

      packages = forAllPkgs (pkgs: rec {
        default = app;
        app = pkgs.callPackage ./package.nix { inherit gitignore; };
      });
      apps = forAllSystems (system: rec {
        default = app;
        app = mkApp (getExe self.packages.${system}.app);
      });

      devShells = forAllPkgs (pkgs:
        let
          inherit (pkgs) lib;
          file-rust-toolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
          rust-toolchain = file-rust-toolchain.override { extensions = [ "rust-analyzer" ]; };
        in
        {
          default = pkgs.mkShell rec {
            nativeBuildInputs = with pkgs; [
              pkg-config
              rust-toolchain
              act
            ];

            buildInputs = [ ];

            RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
            LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
          };
        });
    };
}
