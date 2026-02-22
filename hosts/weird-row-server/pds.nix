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

    services.caddy.virtualHosts.${globals.domains.pds} = {
      serverAliases = [ "*.${globals.domains.pds}" ];
      extraConfig = ''
        	tls /var/lib/agnos/pds.wiro.world_fullchain.pem /var/lib/agnos/pds.wiro.world_privkey.pem
          reverse_proxy http://localhost:${toString config.services.bluesky-pds.settings.PDS_PORT}
      '';
    };
  };
}
