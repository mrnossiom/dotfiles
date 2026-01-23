{
  config,
  ...
}:

let
  authelia-port = 3008;
  authelia-hostname = "auth.wiro.world";

  authelia-metrics-port = 9004;
  headscale-hostname = "headscale.wiro.world";
  grafana-hostname = "console.wiro.world";
  miniflux-hostname = "news.wiro.world";
in
{
  config = {
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
        server.address = "localhost:${toString authelia-port}";
        storage.local.path = "/var/lib/authelia-main/db.sqlite3";
        telemetry.metrics = {
          enabled = true;
          address = "tcp://:${toString authelia-metrics-port}/metrics";
        };

        session = {
          cookies = [
            {
              domain = "wiro.world";
              authelia_url = "https://${authelia-hostname}";
              default_redirection_url = "https://wiro.world";
            }
          ];
        };

        authentication_backend.ldap = {
          address = "ldap://localhost:3890";
          timeout = "5m"; # replace with systemd dependency

          user = "uid=authelia,ou=people,dc=wiro,dc=world";
          # Set in `AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE`.
          # password = "";

          base_dn = "dc=wiro,dc=world";
          users_filter = "(&(|({username_attribute}={input})({mail_attribute}={input}))(objectClass=person))";
          additional_users_dn = "ou=people";
          groups_filter = "(&(member={dn})(objectClass=groupOfNames))";
          additional_groups_dn = "ou=groups";

          attributes = {
            username = "uid";
            display_name = "cn";
            given_name = "givenname";
            family_name = "last_name";
            mail = "mail";
            picture = "avatar";

            group_name = "cn";
          };
        };

        access_control = {
          default_policy = "deny";
          # Rules are sequential and do not apply to OIDC
          rules = [
            {
              domain = "headscale.wiro.world";
              policy = "two_factor";

            }
            {
              domain = "news.wiro.world";
              policy = "one_factor";

              subject = [
                [
                  "group:miniflux"
                  "oauth2:client:miniflux"
                ]
              ];
            }
            {
              domain = "*.wiro.world";
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

          claims_policies.headscale = {
            id_token = [
              "email"
              "name"
              "preferred_username"
              "picture"
              "groups"
            ];
          };

          clients = [
            {
              client_name = "Headscale";
              client_id = "headscale";
              client_secret = "$pbkdf2-sha256$310000$XY680D9gkSoWhD0UtYHNFg$ptWB3exOYCga6uq1N.oimuV3ILjK3F8lBWBpsBpibos";
              redirect_uris = [ "https://${headscale-hostname}/oidc/callback" ];
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
              redirect_uris = [ "https://${grafana-hostname}/login/generic_oauth" ];
              authorization_policy = "grafana";
            }
            {
              client_name = "Miniflux";
              client_id = "miniflux";
              client_secret = "$pbkdf2-sha256$310000$uPqbWfCOBXDY6nV1vsx3uA$HOWG2hL.c/bs9Dwaee3b9DxjH7KFO.SaZMbasXV9Vdw";
              redirect_uris = [ "https://${miniflux-hostname}/oauth2/oidc/callback" ];
              authorization_policy = "miniflux";
            }
          ];
        };

        notifier.smtp = {
          address = "smtp://smtp.resend.com:2587";
          username = "resend";
          # Set in `AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE`.
          # password = "";
          sender = "authelia@wiro.world";
        };
      };
    };

    services.caddy = {
      virtualHosts.${authelia-hostname}.extraConfig = ''
        reverse_proxy http://localhost:${toString authelia-port}
      '';
    };
  };
}
