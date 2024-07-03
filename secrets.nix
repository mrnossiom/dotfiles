let
  inherit (builtins) listToAttrs attrNames;
  mapAttrs' =
    f:
    set:
    listToAttrs (map (attr: f attr set.${attr}) (attrNames set));
in

# You can use agenix directly at repo top-level instead of having to change directory into `secrets/`
mapAttrs' (name: value: { name = ("secrets/" + name); inherit value; }) (import ./secrets/secrets.nix)
