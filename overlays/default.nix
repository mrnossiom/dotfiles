{ self
, lib
, ...
}:

let
  inherit (lib) composeManyExtensions;
in
rec {
  # Bundles all overlays, order matters here
  all = composeManyExtensions [ bringSpecialArgs patches ];

  # Bring `self`, `llib` and `upkgs`
  bringSpecialArgs = final: prev: self.flake-lib.specialModuleArgs final;

  # Custom derivation patches that temporarily fix a package
  patches = import ./patches.nix;
}
