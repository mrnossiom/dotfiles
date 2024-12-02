{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs }:
    let
      inherit (nixpkgs.lib) genAttrs;

      forAllSystems = genAttrs [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forAllPkgs = function: forAllSystems (system: function pkgs.${system});

      mkApp = (program: { type = "app"; inherit program; });

      pkgs = forAllSystems (system: (import nixpkgs {
        inherit system;
        overlays = [ ];
      }));
    in
    {
      formatter = forAllPkgs (pkgs: pkgs.nixpkgs-fmt);

      packages = forAllPkgs (pkgs: rec {
        # default = app;
        # app = pkgs.callPackage ./package.nix { inherit gitignore; };
      });
      apps = forAllSystems (system: rec {
        # default = app;
        # app = mkApp (pkgs.getExe self.packages.${system}.app);
      });

      devShells = forAllPkgs (pkgs:
        with pkgs.lib;
        let
          # key = value;
        in
        {
          default = pkgs.mkShell rec {
            nativeBuildInputs = with pkgs; [
              # hello
            ];
            buildInputs = with pkgs; [
              # openssl
            ];

            LD_LIBRARY_PATH = makeLibraryPath buildInputs;

            # ENV_VAR = "true";
          };
        });
    };
}
