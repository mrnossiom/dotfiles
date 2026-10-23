{ self, ... }:
{
  flake.modules.nixos.weird_row-bluesky-pds = { config, upkgs, ... }: {
    config = {
      local.ports.pds = 3001;

      sops.secrets."pds/jwt_secret" = { };
      sops.secrets."pds/admin_password" = { };
      sops.secrets."pds/plc_rotation_key_k256_private_key_hex" = { };
      sops.secrets."pds/smtp_url" = { };

      sops.templates."bluesky-pds.env".content = ''
        PDS_JWT_SECRET=${config.sops.placeholder."pds/jwt_secret"}
        PDS_ADMIN_PASSWORD=${config.sops.placeholder."pds/admin_password"}
        PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX=${
          config.sops.placeholder."pds/plc_rotation_key_k256_private_key_hex"
        }
        PDS_EMAIL_SMTP_URL=${config.sops.placeholder."pds/smtp_url"}
      '';

      services.bluesky-pds = {
        enable = true;
        package = upkgs.bluesky-pds;

        environmentFiles = [
          config.sops.templates."bluesky-pds.env".path
        ];

        settings = {
          PDS_HOSTNAME = "pds.wiro.world";
          PDS_PORT = config.local.ports.pds.number;

          LOG_DESTINATION = "/tmp/pds.log";

          PDS_EMAIL_FROM_ADDRESS = "pds@services.wiro.world";

          # PDS_DATA_DIRECTORY = "/mnt/bluesky";
        };
      };

      services.caddy.virtualHosts.${self.globals.domains.pds} = {
        serverAliases = [ "*.${self.globals.domains.pds}" ];
        extraConfig = ''
          	tls /var/lib/agnos/pds.wiro.world_fullchain.pem /var/lib/agnos/pds.wiro.world_privkey.pem
            reverse_proxy http://localhost:${toString config.services.bluesky-pds.settings.PDS_PORT}
        '';
      };
    };
  };
}
