{ pkgs
, config
, ...
}:

let
  json-format = pkgs.formats.json { };

  headscale-port = 3006;
  headscale-derp-port = 3478;
  headscale-hostname = "headscale.wiro.world";

  headscale-metrics-port = 9003;
in
{
  config = {
    networking.firewall.allowedUDPPorts = [ headscale-derp-port ];

    age.secrets.headscale-oidc-secret = { file = secrets/headscale-oidc-secret.age; owner = config.services.headscale.user; };
    services.headscale = {
      enable = true;

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
    # headscale only starts if oidc is available
    systemd.services.headscale.after = [ "authelia-main.service" ];

    services.caddy = {
      virtualHosts.${headscale-hostname}.extraConfig = ''
        reverse_proxy http://localhost:${toString headscale-port}
      '';
    };
  };
}
