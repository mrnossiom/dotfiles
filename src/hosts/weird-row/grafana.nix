{ self, ... }:
{
  flake.modules.nixos.weird_row-grafana =
    { config, ... }:
    {
      config = {
        local.ports.grafana = 3002;
        local.ports.prometheus = 9001;
        local.ports.prometheus-exporter-node = 9002;
        local.ports.prometheus-exporter-systemd = 9006;
        local.ports.prometheus-exporter-process = 9008;

        sops.secrets."grafana/secret_key" = {
          owner = "grafana";
        };
        sops.secrets."grafana/oidc_secret" = {
          owner = "grafana";
        };
        sops.secrets."grafana/smtp_password" = {
          owner = "grafana";
        };

        sops.secrets."grafana/contact_nfty_topic" = { };
        sops.templates."grafana.env".content = ''
          CONTACT_NTFY_TOPIC=${config.sops.placeholder."grafana/contact_nfty_topic"}
        '';

        systemd.services.grafana.serviceConfig.EnvironmentFile = config.sops.templates."grafana.env".path;

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

          provision = {
            enable = true;

            datasources.settings.datasources = [
              {
                name = "Prometheus";
                type = "prometheus";
                uid = "prometheus";
                access = "proxy";
                url = "http://localhost:${toString config.services.prometheus.port}";
              }
              {
                name = "Loki";
                type = "loki";
                uid = "loki";
                access = "proxy";
                url = "http://localhost:${toString config.services.loki.configuration.server.http_listen_port}";
              }
            ];

            alerting.contactPoints.settings.contactPoints =
              let
                orgId = 1;
              in
              [
                {
                  inherit orgId;
                  name = "default";
                  receivers = [
                    {
                      uid = "default-name";
                      type = "email";
                      settings.addresses = "milo@wiro.world";
                    }
                    {
                      uid = "default-webhook-nfty";
                      type = "webhook";
                      settings.url = "https://ntfy.sh/$CONTACT_NTFY_TOPIC?template=grafana";
                    }
                  ];
                }
              ];

            # dashboards.settings.providers = [
            #   { name = ""; options.path = "/etc/grafana-dashboards"; }
            # ];
          };
        };

        services.prometheus = {
          enable = true;
          port = config.local.ports.prometheus.number;

          exporters = {
            node = {
              enable = true;
              port = config.local.ports.prometheus-exporter-node.number;
            };

            systemd = {
              enable = true;
              port = config.local.ports.prometheus-exporter-systemd.number;
            };

            # process = {
            #   enable = true;
            #   port = config.local.ports.prometheus-exporter-process.number;
            #   settings.process_names = [
            #     {
            #       name = "jellyfin";
            #       comm = [ "jellyfin" ];
            #     }
            #   ];
            # };

            # blackbox = {
            #   enable = true;
            #   port = config.local.ports.prometheus-exporter-blackbox.number;
            #   settings = { };
            # };
          };

          globalConfig = {
            scrape_interval = "15s";
            evaluation_interval = "15s";
          };

          scrapeConfigs =
            let
              mkLocalScrapeConfig = job_name: port: {
                inherit job_name;
                static_configs = [
                  { targets = [ "localhost:${toString port}" ]; }
                ];
              };
            in
            [
              (mkLocalScrapeConfig "node-exporter" config.services.prometheus.exporters.node.port)
              (mkLocalScrapeConfig "systemd" config.services.prometheus.exporters.systemd.port)
              # (mkLocalScrapeConfig "process" config.services.prometheus.exporters.process.port)
              # (mkLocalScrapeConfig "blackbox" config.services.prometheus.exporters.blackbox.port)
            ];
        };

        local.tailscale.net.binds.console = {
          enable = true;
          domain = self.globals.domains.grafana;
          port = config.local.ports.grafana.number;
        };
      };
    };
}
