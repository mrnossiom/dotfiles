{
  config,
  pkgs,
  globals,
  ...
}:

let
  json-format = pkgs.formats.json { };
in
{
  config = {
    local.ports.headscale = 3006;
    local.ports.headscale-metrics = 9003;
    local.ports.headscale-derp = {
      number = 3478;
      public = true;
      tcp = false;
      udp = true;
    };

    age.secrets.headscale-oidc-secret = {
      file = secrets/headscale-oidc-secret.age;
      owner = config.services.headscale.user;
    };
    services.headscale = {
      enable = true;

      port = config.local.ports.headscale.number;
      settings = {
        server_url = "https://${globals.domains.headscale}";
        metrics_listen_addr = "127.0.0.1:${config.local.ports.headscale-metrics.string}";

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
          nameservers.global = [
            "9.9.9.9"
            "149.112.112.112"
            "2620:fe::fe"
            "2620:fe::9"
          ];
        };

        oidc = {
          only_start_if_oidc_is_available = true;
          issuer = "https://auth.wiro.world";
          client_id = "headscale";
          client_secret_path = config.age.secrets.headscale-oidc-secret.path;
          scope = [
            "openid"
            "profile"
            "email"
            "groups"
          ];
          pkce.enabled = true;
        };

        derp.server = {
          enable = true;
          stun_listen_addr = "0.0.0.0:${config.local.ports.headscale-derp.string}";
        };
      };
    };

    # headscale only starts if oidc is available
    systemd.services.headscale.after = [ "authelia-main.service" ];

    services.prometheus.scrapeConfigs = [
      {
        job_name = "headscale";
        static_configs = [ { targets = [ "localhost:${config.local.ports.headscale-metrics.string}" ]; } ];
      }
    ];

    services.caddy = {
      virtualHosts.${globals.domains.headscale}.extraConfig = ''
        reverse_proxy http://localhost:${config.local.ports.headscale.string}
      '';
    };
  };
}
