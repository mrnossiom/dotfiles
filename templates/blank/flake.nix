{
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
  };

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs.lib) genAttrs;

      forAllSystems = genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllPkgs = function: forAllSystems (system: function pkgs.${system});

      pkgs = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          overlays = [ ];
        }
      );
    in
    {
      formatter = forAllPkgs (pkgs: pkgs.nixfmt-tree);

      devShells = forAllPkgs (pkgs: {
        default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            # hello
          ];
        };
      });
    };
}
