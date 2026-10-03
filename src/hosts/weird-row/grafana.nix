{ self, ... }:
{
  flake.modules.nixos.weird_row-grafana = { config, ... }: {
    config = {
      local.ports.grafana = 3002;
      local.ports.prometheus = 9001;
      local.ports.prometheus-exporter-node = 9002;
      local.ports.prometheus-exporter-systemd = 9006;

      sops.secrets."grafana/secret_key" = {
        owner = "grafana";
      };
      sops.secrets."grafana/oidc_secret" = {
        owner = "grafana";
      };
      sops.secrets."grafana/smtp_password" = {
        owner = "grafana";
      };

      services.grafana = {
        enable = true;

        settings = {
          server = {
            http_port = config.local.ports.grafana.number;
            domain = self.globals.domains.grafana;
            root_url = "https://${self.globals.domains.grafana}";
          };

          security.secret_key = "$__file{${config.sops.secrets."grafana/secret_key".path}}";

          "auth.generic_oauth" = {
            enabled = true;
            name = "wiro.world SSO";
            icon = "signin";

            client_id = "grafana";
            client_secret = "$__file{${config.sops.secrets."grafana/oidc_secret".path}}";
            auto_login = true;
            auth_style = "InHeader";

            login_attribute_path = "preferred_username";
            groups_attribute_path = "groups";
            name_attribute_path = "name";

            role_attribute_path = builtins.concatStringsSep " || " [
              "contains(groups[*], 'admin') && 'GrafanaAdmin'" # instance admin
              "contains(groups[*], 'service:grafana:admin') && 'Admin'" # org admin
              "contains(groups[*], 'service:grafana:editor') && 'Editor'"
              "contains(groups[*], 'service:grafana') && 'Viewer'"
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
            password = "$__file{${config.sops.secrets."grafana/smtp_password".path}}";

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
          port = config.local.ports.prometheus-exporter-node.number;
        };

        exporters.systemd = {
          enable = true;
          port = config.local.ports.prometheus-exporter-systemd.number;
        };

        scrapeConfigs = [
          {
            job_name = "node-exporter";
            static_configs = [
              { targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ]; }
            ];
          }
          {
            job_name = "systemd";
            static_configs = [
              { targets = [ "localhost:${toString config.services.prometheus.exporters.systemd.port}" ]; }
            ];
          }
        ];
      };

      services.caddy.globalConfig = ''
        metrics { per_host }
      '';

      local.tailscale.net.binds.console = {
        enable = true;
        domain = self.globals.domains.grafana;
        port = config.local.ports.grafana.number;
      };
    };
  };
}
