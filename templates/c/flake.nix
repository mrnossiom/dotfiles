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
        with pkgs.lib;
        let
          mkClangShell = pkgs.mkShell.override { stdenv = pkgs.clangStdenv; };
        in
        {
          default = mkClangShell rec {
            nativeBuildInputs = with pkgs; [
              clang-tools
            ] ++ (with llvmPackages; [ clang lldb ]);

            buildInputs = with pkgs; [ ];

            LD_LIBRARY_PATH = makeLibraryPath buildInputs;
          };
        });
    };
}
