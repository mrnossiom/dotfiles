{ config
, ...
}:

let
  pds-port = 3001;
  pds-hostname = "pds.wiro.world";
in
{
  config = {
    age.secrets.pds-env.file = secrets/pds-env.age;
    services.bluesky-pds = {
      enable = true;

      settings = {
        PDS_HOSTNAME = "pds.wiro.world";
        PDS_PORT = pds-port;
        # is in systemd /tmp subfolder
        LOG_DESTINATION = "/tmp/pds.log";
      };

      environmentFiles = [
        config.age.secrets.pds-env.path
      ];
    };

    services.caddy = {
      globalConfig = ''
        on_demand_tls {
          ask http://localhost:${toString pds-port}/tls-check
        }
      '';

      virtualHosts.${pds-hostname} = {
        serverAliases = [ "*.${pds-hostname}" ];
        extraConfig = ''
          	tls { on_demand }
            reverse_proxy http://localhost:${toString config.services.bluesky-pds.settings.PDS_PORT}
        '';
      };
    };
  };
}
