{ config
, ...
}:

let
  grafana-port = 3002;
  # grafana-hostname = "console.net.wiro.world";
  grafana-hostname = "console.wiro.world";

  prometheus-port = 9001;
  prometheus-node-exporter-port = 9002;
  caddy-metrics-port = 2019;
  authelia-metrics-port = 9004;
  headscale-metrics-port = 9003;
in
{
  config = {
    age.secrets.grafana-oidc-secret = { file = secrets/grafana-oidc-secret.age; owner = "grafana"; };
    services.grafana = {
      enable = true;

      settings = {
        server = {
          http_port = grafana-port;
          domain = grafana-hostname;
          root_url = "https://${grafana-hostname}";
        };

        "auth.generic_oauth" = {
          enable = true;
          name = "Authelia";
          icon = "signin";

          client_id = "grafana";
          client_secret_path = config.age.secrets.grafana-oidc-secret.path;
          auto_login = true;

          role_attribute_path = "contains(roles[*], 'admin') && 'GrafanaAdmin' || contains(roles[*], 'editor') && 'Editor' || 'Viewer'";
          allow_assign_grafana_admin = true;

          scopes = [ "openid" "profile" "email" "groups" ];
          auth_url = "https://auth.wiro.world/api/oidc/authorization";
          token_url = "https://auth.wiro.world/api/oidc/token";
          api_url = "https://auth.wiro.world/api/oidc/userinfo";
          use_pkce = true;
        };
      };
    };

    services.prometheus = {
      enable = true;
      port = prometheus-port;

      exporters.node = {
        enable = true;
        port = prometheus-node-exporter-port;
      };

      scrapeConfigs = [
        {
          job_name = "caddy";
          static_configs = [{ targets = [ "localhost:${toString caddy-metrics-port}" ]; }];
        }
        {
          job_name = "node-exporter";
          static_configs = [{ targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ]; }];
        }
        {
          job_name = "headscale";
          static_configs = [{ targets = [ "localhost:${toString headscale-metrics-port}" ]; }];
        }
        {
          job_name = "authelia";
          static_configs = [{ targets = [ "localhost:${toString authelia-metrics-port}" ]; }];
        }
      ];
    };

    services.caddy = {
      globalConfig = ''
        metrics { per_host }
      '';
      # virtualHosts."http://${grafana-hostname}".extraConfig = ''
      # bind tailscale/console
      virtualHosts.${grafana-hostname}.extraConfig = ''
        reverse_proxy http://localhost:${toString grafana-port}
      '';
    };
  };
}
