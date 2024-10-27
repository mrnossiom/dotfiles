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

  options.local.fragment.agenix.enable = lib.mkEnableOption ''
    Agenix secrets manager

    Depends on:
    - `openssh` services: needs host machine keys
  '';

  config = lib.mkIf cfg.enable {
    assertions = [
      { assertion = config.services.openssh.enable; message = "`agenix` fragement depends on `openssh` program"; }
    ];

    age = {
      # By default, agenix uses host machine keys (aka `openssh.hostKeys`).
      # These are always available at boot in opposition to user one that might
      # be located on luks protected partitions.
      # identityPaths = [ ];

      secrets = all-secrets.nixos;
    };
  };
}

