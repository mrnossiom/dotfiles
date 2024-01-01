{ self
, lib
, ...
}:

let
  inherit (self.inputs) nixpkgs-unstable;
  inherit (lib) composeManyExtensions;
in
rec {
  all = composeManyExtensions [ local-lib additions patches unstable-packages ];

  # Merge our local library to nixpkgs'
  local-lib = final: prev: {
    lib = { local = import ../lib final; } // prev.lib;
  };

  # Bring our custom packages from the `pkgs` directory
  additions = final: prev: import ../pkgs prev;

  # Custom derivation patches
  patches = import ./patches.nix;

  # Makes the unstable nixpkgs set accessible through `pkgs.unstable`
  unstable-packages = final: prev: {
    unstable = import nixpkgs-unstable { inherit (final) system config; };
  };
}
