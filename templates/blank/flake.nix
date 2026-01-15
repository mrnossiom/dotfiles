{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      inherit (nixpkgs.lib) genAttrs;

      forAllSystems = genAttrs [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forAllPkgs = function: forAllSystems (system: function pkgs.${system});

      pkgs = forAllSystems (system: (import nixpkgs {
        inherit system;
        overlays = [ ];
      }));
    in
    {
      formatter = forAllPkgs (pkgs: pkgs.nixpkgs-fmt);

      devShells = forAllPkgs (pkgs:
        let
          inherit (pkgs) lib;
        in
        {
          default = pkgs.mkShell rec {
            nativeBuildInputs = with pkgs; [
              # hello
            ];

            buildInputs = [ ];

            LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
          };
        });
    };
}
