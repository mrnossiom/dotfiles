{
  flake.modules.nixos.weird_row-caddy = { config, ... }: {
    config = {
      local.ports.caddy-http = {
        number = 80;
        public = true;
      };
      local.ports.caddy-https = {
        number = 443;
        public = true;
      };
      local.ports.caddy-metrics = 2019;

      age.secrets.caddy-env.file = secrets/caddy-env.age;

      # ensure caddy can access dns challenge wildcard certificates
      users.users.caddy.extraGroups = [ "agnos" ];

      services.caddy = {
        enable = true;
        environmentFile = config.age.secrets.caddy-env.path;
      };

      services.prometheus.scrapeConfigs = [
        {
          job_name = "caddy";
          static_configs = [ { targets = [ "localhost:${config.local.ports.caddy-metrics.string}" ]; } ];
        }
      ];
    };
  };
}
