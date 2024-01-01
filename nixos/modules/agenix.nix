{ self
, config
, ...
}:

let
  inherit (self.inputs) agenix;
in
{
  imports = [ agenix.nixosModules.default ../../secrets ];
  config.age.identityPaths = [ "/home/${config.local.user.username}/.ssh/id_ed25519" ];
}

