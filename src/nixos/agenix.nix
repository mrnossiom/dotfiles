{ inputs, ... }:
let
  mkAgenixModule =
    isDarwin:
    { config, ... }:
    {
      imports = [
        (if isDarwin then inputs.agenix.darwinModules.default else inputs.agenix.nixosModules.default)
      ];

      config = {
        assertions = [
          {
            assertion = config.services.openssh.enable;
            message = "'agenix' depends on 'openssh' service: needs host machine keys";
          }
        ];

        age = {
          # By default, agenix uses host machine keys (aka `openssh.hostKeys`).
          # These are always available at boot in opposition to user one that might
          # be located on luks protected partitions.
          # identityPaths = [ ];

          # Secrets are defined in the modules they are used
          # secrets = ...;
        };
      };
    };
in
{
  flake.modules.nixos.agenix = mkAgenixModule false;
  flake.modules.darwin.agenix = mkAgenixModule true;
}
