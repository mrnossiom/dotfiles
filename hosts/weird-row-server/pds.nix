{
  config,
  globals,
  ...
}:

{
  config = {
    local.ports.pds = 3001;

    age.secrets.pds-env.file = secrets/pds-env.age;
    services.bluesky-pds = {
      enable = true;

      settings = {
        PDS_HOSTNAME = "pds.wiro.world";
        PDS_PORT = config.local.ports.pds.number;
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
          ask http://localhost:${config.local.ports.pds.string}/tls-check
        }
      '';

      virtualHosts.${globals.domains.pds} = {
        # TODO: use wildcard certificate
        serverAliases = [ "*.${globals.domains.pds}" ];
        extraConfig = ''
          	tls { on_demand }
            reverse_proxy http://localhost:${toString config.services.bluesky-pds.settings.PDS_PORT}
        '';
      };
    };
  };
}
