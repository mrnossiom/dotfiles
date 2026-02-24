{
  config,
  pkgs,
  globals,
  ...
}:

{
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
      package = pkgs.caddy.withPlugins {
        plugins = [
          "github.com/tailscale/caddy-tailscale@v0.0.0-20251016213337-01d084e119cb"
        ];
        hash = "sha256-3R2upV1wYmLq4GbedMA7cxRIqLo8WIDnKvDSgUvvjAo=";
      };

      environmentFile = config.age.secrets.caddy-env.path;

      globalConfig = ''
        tailscale {
          # this caddy instance already proxies headscale but needs to access headscale to start
          # control_url https://headscale.wiro.world
          control_url http://localhost:${config.local.ports.headscale.string}

          ephemeral
        }
      '';

      virtualHosts.${globals.domains.website}.extraConfig =
        # TODO: host website on server with automatic deployment
        ''
          reverse_proxy https://mrnossiom.github.io {
          	header_up Host {http.request.host}
          }
        '';
    };

    services.prometheus.scrapeConfigs = [
      {
        job_name = "caddy";
        static_configs = [ { targets = [ "localhost:${config.local.ports.caddy-metrics.string}" ]; } ];
      }
    ];
  };
}
