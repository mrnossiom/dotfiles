{
  config,
  globals,
  ...
}:

{
  config = {
    local.ports.grafana = 3002;
    local.ports.prometheus = 9001;
    local.ports.prometheus-node-exporter = 9002;

    age.secrets.grafana-oidc-secret = {
      file = secrets/grafana-oidc-secret.age;
      owner = "grafana";
    };
    age.secrets.grafana-smtp-password = {
      file = secrets/grafana-smtp-password.age;
      owner = "grafana";
    };

    services.grafana = {
      enable = true;

      settings = {
        server = {
          http_port = config.local.ports.grafana.number;
          domain = globals.domains.grafana;
          root_url = "https://${globals.domains.grafana}";
        };

        "auth.generic_oauth" = {
          enable = true;
          name = "Authelia";
          icon = "signin";

          client_id = "grafana";
          client_secret = "$__file{${config.age.secrets.grafana-oidc-secret.path}}";
          auto_login = true;

          login_attribute_path = "preferred_username";
          groups_attribute_path = "groups";
          name_attribute_path = "name";

          role_attribute_path = builtins.concatStringsSep " || " [
            "contains(groups[*], 'admin') && 'GrafanaAdmin'"
            "contains(groups[*], 'admin') && 'Admin'"
            "contains(groups[*], 'editor') && 'Editor'"
            "'Viewer'"
          ];
          allow_assign_grafana_admin = true;

          scopes = [
            "openid"
            "profile"
            "email"
            "groups"
          ];
          auth_url = "https://auth.wiro.world/api/oidc/authorization";
          token_url = "https://auth.wiro.world/api/oidc/token";
          api_url = "https://auth.wiro.world/api/oidc/userinfo";
          use_pkce = true;
        };

        smtp = {
          enabled = true;
          host = "smtp.resend.com:2587";
          user = "resend";
          password = "$__file{${config.age.secrets.grafana-smtp-password.path}}";

          from_address = "grafana@services.wiro.world";
          from_name = "wiro.world Grafana Alerts";
          startTLS_policy = "MandatoryStartTLS";
        };
      };
    };

    services.prometheus = {
      enable = true;
      port = config.local.ports.prometheus.number;

      exporters.node = {
        enable = true;
        port = config.local.ports.prometheus-node-exporter.number;
      };

      scrapeConfigs = [
        {
          job_name = "node-exporter";
          static_configs = [
            { targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ]; }
          ];
        }
      ];
    };

    services.caddy.globalConfig = ''
      metrics { per_host }
    '';

    services.caddy.virtualHosts.${globals.domains.grafana}.extraConfig = ''
      bind tailscale/console
      tls /var/lib/agnos/net.wiro.world_fullchain.pem /var/lib/agnos/net.wiro.world_privkey.pem
      reverse_proxy http://localhost:${config.local.ports.grafana.string}
    '';
  };
}
