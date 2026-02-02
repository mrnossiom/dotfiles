{
  config,
  globals,
  ...
}:

{
  config = {
    local.ports.authelia = 3008;
    local.ports.authelia-metrics = 9004;

    age.secrets.authelia-jwt-secret = {
      file = secrets/authelia-jwt-secret.age;
      owner = config.services.authelia.instances.main.user;
    };
    age.secrets.authelia-issuer-private-key = {
      file = secrets/authelia-issuer-private-key.age;
      owner = config.services.authelia.instances.main.user;
    };
    age.secrets.authelia-storage-key = {
      file = secrets/authelia-storage-key.age;
      owner = config.services.authelia.instances.main.user;
    };
    age.secrets.authelia-ldap-password = {
      file = secrets/authelia-ldap-password.age;
      owner = config.services.authelia.instances.main.user;
    };
    age.secrets.authelia-smtp-password = {
      file = secrets/authelia-smtp-password.age;
      owner = config.services.authelia.instances.main.user;
    };
    services.authelia.instances.main = {
      enable = true;

      secrets = {
        jwtSecretFile = config.age.secrets.authelia-jwt-secret.path;
        oidcIssuerPrivateKeyFile = config.age.secrets.authelia-issuer-private-key.path;
        storageEncryptionKeyFile = config.age.secrets.authelia-storage-key.path;
      };
      environmentVariables = {
        AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = config.age.secrets.authelia-ldap-password.path;
        AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = config.age.secrets.authelia-smtp-password.path;
      };
      settings = {
        server.address = "localhost:${config.local.ports.authelia.string}";
        storage.local.path = "/var/lib/authelia-main/db.sqlite3";
        telemetry.metrics = {
          enabled = true;
          address = "tcp://:${config.local.ports.authelia-metrics.string}/metrics";
        };

        session = {
          cookies = [
            {
              domain = globals.domains.wiro-world;
              authelia_url = "https://${globals.domains.authelia}";
              default_redirection_url = "https://${globals.domains.website}";
            }
          ];
        };

        authentication_backend.ldap = {
          implementation = "lldap";
          address = "ldap://localhost:${config.local.ports.lldap-ldap.string}";
          base_dn = "dc=wiro,dc=world";

          user = "uid=authelia,ou=people,dc=wiro,dc=world";
          # Set in `AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE`.
          # password = "";
        };

        access_control = {
          default_policy = "deny";
          # Rules are sequential and do not apply to OIDC
          rules = [
            {
              domain = globals.domains.headscale;
              policy = "two_factor";
            }
            {
              domain = globals.domains.miniflux;
              policy = "one_factor";

              subject = [
                [
                  "group:miniflux"
                  "oauth2:client:miniflux"
                ]
              ];
            }
            {
              domain = "*.${globals.domains.wiro-world}";
              policy = "two_factor";
            }
          ];
        };

        identity_providers.oidc = {
          enforce_pkce = "always";

          authorization_policies =
            let
              mkStrictPolicy = policy: subject: {
                default_policy = "deny";
                rules = [ { inherit policy subject; } ];
              };
            in
            {
              headscale = mkStrictPolicy "two_factor" [ "group:headscale" ];
              tailscale = mkStrictPolicy "two_factor" [ "group:headscale" ];
              grafana = mkStrictPolicy "one_factor" [ "group:grafana" ];
              miniflux = mkStrictPolicy "one_factor" [ "group:miniflux" ];
            };

          claims_policies = {
            headscale.id_token = [
              "email"
              "name"
              "preferred_username"
              "picture"
              "groups"
            ];
            grafana.id_token = [
              "email"
              "name"
              "groups"
              "preferred_username"
            ];
          };

          clients = [
            {
              client_name = "Headscale";
              client_id = "headscale";
              client_secret = "$pbkdf2-sha256$310000$XY680D9gkSoWhD0UtYHNFg$ptWB3exOYCga6uq1N.oimuV3ILjK3F8lBWBpsBpibos";
              redirect_uris = [ "https://${globals.domains.headscale}/oidc/callback" ];
              authorization_policy = "headscale";
              claims_policy = "headscale";
            }
            {
              client_name = "Tailscale";
              client_id = "tailscale";
              client_secret = "$pbkdf2-sha256$310000$PcUaup9aWKI9ZLeCF6.avw$FpsTxkDaxcoQlBi8aIacegXpjEDiCI6nXcaHyZ2Sxyc";
              redirect_uris = [ "https://login.tailscale.com/a/oauth_response" ];
              authorization_policy = "tailscale";
            }
            {
              client_name = "Grafana Console";
              client_id = "grafana";
              client_secret = "$pbkdf2-sha256$310000$UkwrqxTZodGMs9.Ca2cXAA$HCWFgQbFHGXZpuz.I3HHdkTZLUevRVGlhKEFaOlPmKs";
              redirect_uris = [ "https://${globals.domains.grafana}/login/generic_oauth" ];
              authorization_policy = "grafana";
              claims_policy = "grafana";
            }
            {
              client_name = "Miniflux";
              client_id = "miniflux";
              client_secret = "$pbkdf2-sha256$310000$uPqbWfCOBXDY6nV1vsx3uA$HOWG2hL.c/bs9Dwaee3b9DxjH7KFO.SaZMbasXV9Vdw";
              redirect_uris = [ "https://${globals.domains.miniflux}/oauth2/oidc/callback" ];
              authorization_policy = "miniflux";
            }
          ];
        };

        notifier.smtp = {
          address = "smtp://smtp.resend.com:2587";
          username = "resend";
          # Set in `AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE`.
          # password = "";
          sender = "authelia@services.wiro.world";
        };
      };
    };

    systemd.services.authelia.after = [ "lldap.service" ];

    services.prometheus.scrapeConfigs = [
      {
        job_name = "authelia";
        static_configs = [ { targets = [ "localhost:${config.local.ports.authelia-metrics.string}" ]; } ];
      }
    ];

    services.caddy = {
      virtualHosts.${globals.domains.authelia}.extraConfig = ''
        reverse_proxy http://localhost:${config.local.ports.authelia.string}
      '';
    };
  };
}
