{ self
, config
, lib

, isDarwin
, ...
}:

let
  inherit (self.inputs) agenix;

  cfg = config.local.fragment.agenix;
  all-secrets = import ../../secrets;
in
{
  imports = [
    (if isDarwin then agenix.darwinModules.default else agenix.nixosModules.default)
  ];

  # TODO: enforce dependance
  options.local.fragment.agenix.enable = lib.mkEnableOption ''
    Agenix secrets manager

    Depends on: OpenSSH (`security`)
  '';

  config = lib.mkIf cfg.enable {
    # By default, agenix uses host machine keys (aka `openssh.hostKeys`).
    # These are always available at boot in opposition to user one that might
    # be located on luks protected partitions.
    # age.identityPaths = [ ];

    age.secrets = all-secrets.nixos;
  };
}

