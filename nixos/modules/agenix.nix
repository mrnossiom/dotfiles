{ self
, config
, ...
}:

let
  inherit (self.inputs) agenix;
in
{
  imports = [ agenix.nixosModules.default ../../secrets ];

  config = {
    # By default, agenix uses host machine keys
    # It is better than user ones since they are not always available at boot
    # (e.g btrfs with luks doesn't load home partition right away)
    # age.identityPaths = [ ];
  };
}

