{ self
, config
, pkgs
, upkgs
, ...
}:

let
  inherit (self.inputs) unixpkgs srvos hypixel-bank-tracker tangled;

  json-format = pkgs.formats.json { };

  ext-if = "eth0";
  external-ip = "91.99.55.74";
  external-netmask = 27;
  external-gw = "144.x.x.255";
  external-ip6 = "2a01:4f8:c2c:76d2::1";
  external-netmask6 = 64;
  external-gw6 = "fe80::1";

  well-known-discord-dir = pkgs.writeTextDir ".well-known/discord" ''
    dh=919234284ceb2aba439d15b9136073eb2308989b
  '';
  webfinger-dir = pkgs.writeTextDir ".well-known/webfinger" ''
    {
      "subject": "acct:milo@wiro.world",
      "aliases": [
        "mailto:milo@wiro.world",
        "https://wiro.world/"
      ],
      "links": [
        {
          "rel": "http://wiro.world/rel/avatar",
          "href": "https://wiro.world/logo.jpg",
          "type": "image/jpeg"
        },
        {
          "rel": "http://webfinger.net/rel/profile-page",
          "href": "https://wiro.world/",
          "type": "text/html"
        },
        {
          "rel": "http://openid.net/specs/connect/1.0/issuer",
          "href": "https://auth.wiro.world"
        }
      ]
    }
  '';

  website-hostname = "wiro.world";

  pds-port = 3001;
  pds-hostname = "pds.wiro.world";

  grafana-port = 3002;
  grafana-hostname = "console.wiro.world";

  tangled-owner = "did:plc:xhgrjm4mcx3p5h3y6eino6ti";
  tangled-knot-port = 3003;
  tangled-knot-hostname = "knot.wiro.world";
  tangled-spindle-port = 3004;
  tangled-spindle-hostname = "spindle.wiro.world";

  thelounge-port = 3005;
  thelounge-hostname = "lounge.wiro.world";

  headscale-port = 3006;
  headscale-derp-port = 3478;
  headscale-hostname = "headscale.wiro.world";

  lldap-port = 3007;
  lldap-hostname = "ldap.wiro.world";

  authelia-port = 3008;
  authelia-hostname = "auth.wiro.world";

  matrix-port = 3009;
  matrix-hostname = "matrix.wiro.world";

  goatcounter-port = 3010;
  goatcounter-hostname = "stats.wiro.world";

  vaultwarden-port = 3011;
  vaultwarden-hostname = "vault.wiro.world";

  miniflux-port = 3012;
  miniflux-hostname = "news.wiro.world";

  hbt-main-port = 3013;
  hbt-banana-port = 3014;

  prometheus-port = 9001;
  prometheus-node-exporter-port = 9002;
  headscale-metrics-port = 9003;
  authelia-metrics-port = 9004;
in
{
  disabledModules = [ "services/networking/headscale.nix" ];

  imports = [
    srvos.nixosModules.server
    srvos.nixosModules.hardware-hetzner-cloud
    srvos.nixosModules.mixins-terminfo

    self.nixosModules.headscale

    hypixel-bank-tracker.nixosModules.default

    tangled.nixosModules.knot
    tangled.nixosModules.spindle

    "${unixpkgs}/nixos/modules/services/matrix/tuwunel.nix"
  ];

  config = {
    boot.loader.grub.enable = true;
    boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" "ext4" ];

    # Single network card is `eth0`
    networking.usePredictableInterfaceNames = false;

    networking.nameservers = [ "2001:4860:4860::8888" "2001:4860:4860::8844" ];

    networking = {
      interfaces.${ext-if} = {
        ipv4.addresses = [{ address = external-ip; prefixLength = external-netmask; }];
        ipv6.addresses = [{ address = external-ip6; prefixLength = external-netmask6; }];
      };
      defaultGateway = { interface = ext-if; address = external-gw; };
      defaultGateway6 = { interface = ext-if; address = external-gw6; };

      # Reflect firewall configuration on Hetzner
      firewall.allowedTCPPorts = [ 22 80 443 ];
      firewall.allowedUDPPorts = [ headscale-derp-port ];
    };

    services.qemuGuest.enable = true;

    services.openssh.enable = true;

    services.tailscale.enable = true;

    security.sudo.wheelNeedsPassword = false;

    local.fragment.nix.enable = true;

    programs.fish.enable = true;

    services.fail2ban = {
      enable = true;

      maxretry = 5;
      ignoreIP = [ ];

      bantime = "24h";
      bantime-increment = {
        enable = true;
        multipliers = "1 2 4 8 16 32 64";
        maxtime = "168h";
        overalljails = true;
      };

      jails = { };
    };

    services.caddy = {
      enable = true;

      globalConfig = ''
        metrics { per_host }

        on_demand_tls {
          ask http://localhost:${toString pds-port}/tls-check
        }
      '';

      virtualHosts.${website-hostname}.extraConfig =
        ''
          @discord {
            path /.well-known/discord
            method GET HEAD
          }
          route @discord {
            header {
              Access-Control-Allow-Origin "*"
              X-Robots-Tag "noindex"
            }
            root ${well-known-discord-dir}
            file_server
          }
        '' +
        ''
          @webfinger {
            path /.well-known/webfinger
            method GET HEAD
            query resource=acct:milo@wiro.world
            query resource=mailto:milo@wiro.world
            query resource=https://wiro.world
            query resource=https://wiro.world/
          }
          route @webfinger {
            header {
              Content-Type "application/jrd+json"
              Access-Control-Allow-Origin "*"
              X-Robots-Tag "noindex"
            }
            root ${webfinger-dir}
            file_server
          }
        '' +
        ''
          reverse_proxy /.well-known/matrix/* http://localhost:${toString matrix-port}
        '' +
        # TODO: host website on server with automatic deployment
        ''
          reverse_proxy https://mrnossiom.github.io {
          	header_up Host {http.request.host}
          }
        '';

      virtualHosts.${grafana-hostname}.extraConfig = ''
        reverse_proxy http://localhost:${toString grafana-port}
      '';

      virtualHosts.${pds-hostname} = {
        serverAliases = [ "*.${pds-hostname}" ];
        extraConfig = ''
          	tls { on_demand }
            reverse_proxy http://localhost:${toString pds-port}
        '';
      };

      virtualHosts.${tangled-knot-hostname}.extraConfig = ''
        reverse_proxy http://localhost:${toString tangled-knot-port}
      '';

      virtualHosts.${tangled-spindle-hostname}.extraConfig = ''
        reverse_proxy http://localhost:${toString tangled-spindle-port}
      '';

      virtualHosts.${thelounge-hostname}.extraConfig = ''
        reverse_proxy http://localhost:${toString thelounge-port}
      '';

      virtualHosts.${headscale-hostname}.extraConfig = ''
        reverse_proxy http://localhost:${toString headscale-port}
      '';

      virtualHosts.${lldap-hostname}.extraConfig = ''
        reverse_proxy http://localhost:${toString lldap-port}
      '';

      virtualHosts.${authelia-hostname}.extraConfig = ''
        reverse_proxy http://localhost:${toString authelia-port}
      '';

      virtualHosts.${matrix-hostname}.extraConfig = ''
        reverse_proxy /_matrix/* http://localhost:${toString matrix-port}
      '';

      virtualHosts.${goatcounter-hostname}.extraConfig = ''
        reverse_proxy http://localhost:${toString goatcounter-port}
      '';

      virtualHosts.${vaultwarden-hostname}.extraConfig = ''
        reverse_proxy http://localhost:${toString vaultwarden-port}
      '';

      virtualHosts.${miniflux-hostname}.extraConfig = ''
        reverse_proxy http://localhost:${toString miniflux-port}
      '';

      virtualHosts."hypixel-bank-tracker.xyz".extraConfig = ''
        reverse_proxy http://localhost:${toString hbt-main-port}
      '';

      virtualHosts."banana.hypixel-bank-tracker.xyz".extraConfig = ''
        reverse_proxy http://localhost:${toString hbt-banana-port}
      '';
    };

    age.secrets.pds-env.file = ../../secrets/pds-env.age;
    services.pds = {
      enable = true;
      package = upkgs.bluesky-pds;

      settings = {
        PDS_HOSTNAME = "pds.wiro.world";
        PDS_PORT = pds-port;
        # is in systemd /tmp subfolder
        LOG_DESTINATION = "/tmp/pds.log";
      };

      environmentFiles = [
        config.age.secrets.pds-env.path
      ];
    };

    services.tangled.knot = {
      enable = true;
      openFirewall = true;

      motd = "Welcome to @wiro.world's knot!\n";
      server = {
        listenAddr = "localhost:${toString tangled-knot-port}";
        hostname = tangled-knot-hostname;
        owner = tangled-owner;
      };
    };

    services.tangled.spindle = {
      enable = true;

      server = {
        listenAddr = "localhost:${toString tangled-spindle-port}";
        hostname = tangled-spindle-hostname;
        owner = tangled-owner;
      };
    };

    age.secrets.grafana-oidc-secret = { file = ../../secrets/grafana-oidc-secret.age; owner = "grafana"; };
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

      scrapeConfigs = [
        {
          job_name = "caddy";
          static_configs = [{ targets = [ "localhost:${toString 2019}" ]; }];
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
        {
          job_name = "miniflux";
          static_configs = [{ targets = [ "localhost:${toString miniflux-port}" ]; }];
        }
      ];

      exporters.node = {
        enable = true;
        port = prometheus-node-exporter-port;
      };
    };

    services.thelounge = {
      enable = true;
      port = thelounge-port;
      public = false;

      extraConfig = {
        host = "127.0.0.1";
        reverseProxy = true;

        # TODO: use ldap, find a way to hide password
      };
    };

    age.secrets.headscale-oidc-secret = { file = ../../secrets/headscale-oidc-secret.age; owner = config.services.headscale.user; };
    # TODO: add dependency on authelia
    services.headscale = {
      enable = true;
      package = upkgs.headscale;

      port = headscale-port;
      settings = {
        server_url = "https://${headscale-hostname}";
        metrics_listen_addr = "127.0.0.1:${toString headscale-metrics-port}";

        policy.path = json-format.generate "policy.json" {
          acls = [
            {
              action = "accept";
              src = [ "autogroup:member" ];
              dst = [ "autogroup:self:*" ];
            }
          ];
          ssh = [
            {
              action = "accept";
              src = [ "autogroup:member" ];
              dst = [ "autogroup:self" ];
              # Adding root here is privilege escalation as a feature :)
              users = [ "autogroup:nonroot" ];
            }
          ];
        };

        # disable TLS
        tls_cert_path = null;
        tls_key_path = null;

        dns = {
          magic_dns = true;
          base_domain = "net.wiro.world";

          override_local_dns = true;
          # Quad9 nameservers
          nameservers.global = [ "9.9.9.9" "149.112.112.112" "2620:fe::fe" "2620:fe::9" ];
        };

        oidc = {
          only_start_if_oidc_is_available = true;
          issuer = "https://auth.wiro.world";
          client_id = "headscale";
          client_secret_path = config.age.secrets.headscale-oidc-secret.path;
          scope = [ "openid" "profile" "email" "groups" ];
          pkce.enabled = true;
        };

        derp.server = {
          enable = true;
          stun_listen_addr = "0.0.0.0:${toString headscale-derp-port}";
        };
      };
    };

    age.secrets.lldap-env.file = ../../secrets/lldap-env.age;
    services.lldap = {
      enable = true;
      settings = {
        http_url = "https://${lldap-hostname}";
        http_port = lldap-port;

        ldap_base_dn = "dc=wiro,dc=world";
      };
      environmentFile = config.age.secrets.lldap-env.path;
    };

    age.secrets.authelia-jwt-secret = { file = ../../secrets/authelia-jwt-secret.age; owner = config.services.authelia.instances.main.user; };
    age.secrets.authelia-issuer-private-key = { file = ../../secrets/authelia-issuer-private-key.age; owner = config.services.authelia.instances.main.user; };
    age.secrets.authelia-storage-key = { file = ../../secrets/authelia-storage-key.age; owner = config.services.authelia.instances.main.user; };
    age.secrets.authelia-ldap-password = { file = ../../secrets/authelia-ldap-password.age; owner = config.services.authelia.instances.main.user; };
    age.secrets.authelia-smtp-password = { file = ../../secrets/authelia-smtp-password.age; owner = config.services.authelia.instances.main.user; };
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
          cookies = [{
            domain = "wiro.world";
            authelia_url = "https://${authelia-hostname}";
            default_redirection_url = "https://wiro.world";
          }];
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

              subject = [ [ "group:miniflux" "oauth2:client:miniflux" ] ];
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
              mkStrictPolicy = policy: subject:
                { default_policy = "deny"; rules = [{ inherit policy subject; }]; };
            in
            {
              headscale = mkStrictPolicy "two_factor" [ "group:headscale" ];
              tailscale = mkStrictPolicy "two_factor" [ "group:headscale" ];
              grafana = mkStrictPolicy "one_factor" [ "group:grafana" ];
              miniflux = mkStrictPolicy "one_factor" [ "group:miniflux" ];
            };

          claims_policies.headscale = { id_token = [ "email" "name" "preferred_username" "picture" "groups" ]; };

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

    age.secrets.tuwunel-registration-tokens = { file = ../../secrets/tuwunel-registration-tokens.age; owner = config.services.matrix-tuwunel.user; };
    services.matrix-tuwunel = {
      enable = true;
      package = upkgs.matrix-tuwunel;

      settings.global = {
        address = [ "127.0.0.1" ];
        port = [ matrix-port ];

        server_name = "wiro.world";
        well_known = {
          client = "https://matrix.wiro.world";
          server = "matrix.wiro.world:443";
        };

        grant_admin_to_first_user = true;
        new_user_displayname_suffix = "";

        allow_registration = true;
        registration_token_file = config.age.secrets.tuwunel-registration-tokens.path;
      };
    };

    services.goatcounter = {
      enable = true;

      port = goatcounter-port;
      proxy = true;
      extraArgs = [ "-automigrate" ];
    };

    age.secrets.vaultwarden-env.file = ../../secrets/vaultwarden-env.age;
    services.vaultwarden = {
      enable = true;
      package = upkgs.vaultwarden;

      environmentFile = config.age.secrets.vaultwarden-env.path;
      config = {
        ROCKET_PORT = vaultwarden-port;
        DOMAIN = "https://${vaultwarden-hostname}";
        SIGNUPS_ALLOWED = false;
        ADMIN_TOKEN = "$argon2id$v=19$m=65540,t=3,p=4$YIe9wmrTsmjgZNPxe8m34O/d3XW3Fl/uZPPLQs79dAc$mjDVQSdBJqz2uBJuxtAvCIoHPzOnTDhNPuhER3dhHrY";

        SMTP_HOST = "smtp.resend.com";
        SMTP_PORT = 2465;
        SMTP_SECURITY = "force_tls";
        SMTP_USERNAME = "resend";
        # SMTP_PASSWORD = ...; # Via secret env
        SMTP_FROM = "bitwarden@wiro.world";
        SMTP_FROM_NAME = "Bitwarden wiro.world";
      };
    };

    users.users.miniflux = { isSystemUser = true; group = "miniflux"; };
    users.groups.miniflux = { };
    age.secrets.miniflux-oidc-secret = { file = ../../secrets/miniflux-oidc-secret.age; owner = "miniflux"; };
    services.miniflux = {
      enable = true;

      createDatabaseLocally = true;
      config = {
        BASE_URL = "https://${miniflux-hostname}/";
        LISTEN_ADDR = "127.0.0.1:${toString miniflux-port}";
        CREATE_ADMIN = 0;

        METRICS_COLLECTOR = 1;

        OAUTH2_PROVIDER = "oidc";
        OAUTH2_OIDC_PROVIDER_NAME = "wiro.world SSO";
        OAUTH2_CLIENT_ID = "miniflux";
        OAUTH2_CLIENT_SECRET_FILE = config.age.secrets.miniflux-oidc-secret.path;
        OAUTH2_REDIRECT_URL = "https://${miniflux-hostname}/oauth2/oidc/callback";
        OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://auth.wiro.world";
        OAUTH2_USER_CREATION = 1;
        DISABLE_LOCAL_AUTH = 1;

        RUN_MIGRATIONS = 1;

        # NetNewsWire is a very good iOS oss client that integrates well
        # https://b.j4.lc/2025/05/05/setting-up-netnewswire-with-miniflux/
      };
    };

    age.secrets.hypixel-bank-tracker-main.file = ../../secrets/hypixel-bank-tracker-main.age;
    services.hypixel-bank-tracker.instances.main = {
      enable = true;

      port = hbt-main-port;
      environmentFile = config.age.secrets.hypixel-bank-tracker-main.path;
    };

    age.secrets.hypixel-bank-tracker-banana.file = ../../secrets/hypixel-bank-tracker-banana.age;
    services.hypixel-bank-tracker.instances.banana = {
      enable = true;

      port = hbt-banana-port;
      environmentFile = config.age.secrets.hypixel-bank-tracker-banana.path;
    };
  };
}
