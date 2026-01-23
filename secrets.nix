let
  inherit (builtins) listToAttrs attrNames;

  # Map the name and value of all items of an attrset
  mapAttrs' = f: set: listToAttrs (map (attr: f attr set.${attr}) (attrNames set));

  keys = import ./secrets/keys.nix;

  prependAttrsName =
    prefix:
    mapAttrs' (
      name: value: {
        name = prefix + name;
        inherit value;
      }
    );
  secretsDir = path: prependAttrsName (path + "/") ((import ./${path}/default.nix) keys);
in

secretsDir "secrets" // secretsDir "hosts/weird-row-server/secrets"
