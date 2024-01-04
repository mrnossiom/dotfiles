{ self
, lib
, ...
}:

let
  inherit (self.inputs) nixpkgs-unstable;
  inherit (lib) composeManyExtensions;
in
rec {
  # Bundles all overlays, order matters here
  all = composeManyExtensions [ addFlakeAsSelf localLib additions patches unstablePackages ];

  # Passing our flake as `self` makes it easy to access inputs and outputs
  addFlakeAsSelf = final: prev: { inherit self; };

  # Merge our local library to nixpkgs'
  localLib = final: prev: {
    lib = { local = import ../lib final; } // prev.lib;
  };

  # Bring our custom packages from the `pkgs` directory
  additions = final: prev: import ../pkgs prev;

  # Custom derivation patches that temporarily fix a package
  patches = import ./patches.nix;

  # Makes the unstable nixpkgs set accessible through `pkgs.unstable`
  unstablePackages = final: prev: {
    unstable = import nixpkgs-unstable { inherit (final) system config; };
  };
}
