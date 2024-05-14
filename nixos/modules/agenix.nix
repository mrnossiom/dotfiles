{ self
, ...
}:

let
  inherit (self.inputs) agenix;

  all-secrets = import ../../secrets;
in
{
  imports = [ agenix.nixosModules.default ];

  config = {
    # By default, agenix uses host machine keys
    # It is better than user ones since they are not always available at boot
    # (e.g btrfs with luks doesn't load home partition right away)
    # age.identityPaths = [ ];

    age.secrets = all-secrets.nixos;
  };
}

