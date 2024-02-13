{ self
, lib
, ...
}:

let
  inherit (lib) composeManyExtensions;
in
rec {
  # Bundles all overlays, order matters here
  all = composeManyExtensions [ bringSpecialArgs additions patches ];

  # Bring `self`, `llib` and `upkgs`
  bringSpecialArgs = final: prev: self.flakeLib.specialModuleArgs final;

  # Bring our custom packages from the `pkgs` directory
  additions = final: prev: import ../pkgs prev;

  # Custom derivation patches that temporarily fix a package
  patches = import ./patches.nix;
}
