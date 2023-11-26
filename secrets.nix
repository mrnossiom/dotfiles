with (import <nixpkgs> { }).lib;

# You can use agenix directly at repo top-level instead of having to change directory into `secrets/`
mapAttrs' (name: value: nameValuePair ("secrets/" + name) value) (import ./secrets/secrets.nix)
