{
  config,
  globals,
  ...
}:

{
  config = {
    local.ports.gatus = 3018;

    age.secrets.gatus-env.file = secrets/gatus-env.age;

    services.gatus = {
      enable = true;
      environmentFile = config.age.secrets.gatus-env.path;

      # GATUS_DELAY_START_SECONDS=10

      settings = {
        web.port = config.local.ports.gatus.number;
        ui = {
          title = "Wiro's World Status";
          header = "Wiro's World Status";
        };

        storage = {
          type = "sqlite";
          path = "/var/lib/gatus/data.db";
        };
        connectivity.checker = {
          target = "1.1.1.1:53";
          interval = "60s";
        };
        alerting.email = {
          from = "gatus@services.wiro.world";

          username = "resend";
          password = "$SMTP_PASSWORD";
          host = "smtp.resend.com";
          port = 2587;
          to = "milo@wiro.world";

          default-alert = {
            description = "health check failed";
            send-on-resolved = true;
            failure-threshold = 3;
            success-threshold = 2;
          };
        };

        endpoints =
          let
            groups = {
              public = "Public";
              auth = "Authenticated";
              net = "Net";
            };

            tests = {
              status200 = "[STATUS] == 200";
              time300 = "[RESPONSE_TIME] <= 500";
              cert1w = "[CERTIFICATE_EXPIRATION] >= 168h";
            };

            mkHttp =
              name: group: url:
              {
                interval ? "5m",
                conditions ? [
                  tests.status200
                  tests.time300
                  tests.cert1w
                ],
                alerts ? [
                  { type = "email"; }
                ],
              }:
              {
                inherit
                  name
                  url
                  group
                  interval
                  conditions
                  alerts
                  ;
              };
          in
          [
            (mkHttp "Website" groups.public "https://${globals.domains.website}/" { })
            (mkHttp "Hypixel Bank Tracker" groups.public "https://${globals.domains.hbt-main}/" { })
            (mkHttp "Hypixel Bank Tracker Banana" groups.public "https://${globals.domains.hbt-banana}/" { })
            (mkHttp "Status" groups.public "https://${globals.domains.status}/" { })

            (mkHttp "Miniflux" groups.auth "https://${globals.domains.miniflux}/" { })
            (mkHttp "Vaultwarden" groups.auth "https://${globals.domains.vaultwarden}/" { })
            (mkHttp "Headscale" groups.auth "https://${globals.domains.headscale}/health" { })
            (mkHttp "Atproto PDS" groups.auth "https://${globals.domains.pds}/xrpc/_health" { })
            (mkHttp "Goat Counter" groups.auth "https://${globals.domains.goatcounter}/" { })

            (mkHttp "Warrior" groups.net "https://${globals.domains.warrior}/" {
              interval = "10m";
              conditions = [ tests.status200 ];
            })
            (mkHttp "Grafana" groups.net "https://${globals.domains.grafana}/" { })
          ];
      };
    };

    services.caddy.virtualHosts.${globals.domains.status}.extraConfig = ''
      reverse_proxy http://localhost:${toString config.services.gatus.settings.web.port}
    '';
  };
}
