{ self, ... }:
{
  flake.modules.nixos.weird_row-rustical =
    {
      config,
      lib,
      upkgs,
      ...
    }:
    {
      config = {
        local.ports.rustical = 3019;

        sops.secrets."rustical/oidc_secret" = { };
        sops.templates."rustical.env".content = ''
          RUSTICAL_OIDC__CLIENT_SECRET=${config.sops.placeholder."rustical/oidc_secret"}
        '';

        # PATCH: needed to use versions above v0.15
        systemd.services.rustical.serviceConfig.ExecStart =
          lib.mkForce "${lib.getExe config.services.rustical.package} serve";

        services.rustical = {
          enable = true;
          package = upkgs.rustical;

          environmentFiles = [
            config.sops.templates."rustical.env".path
          ];

          settings = {
            http = {
              host = "[::]";
              port = config.local.ports.rustical.number;
            };

            oidc = {
              name = "Authelia";
              issuer = "https://${self.globals.domains.authelia}";
              client_id = "rustical";
              # client_secret = <defined in env>;
              claim_userid = "preferred_username";
              scopes = [
                "openid"
                "profile"
                "groups"
              ];
              require_group = "service:rustical";
              allow_sign_up = true;
            };

            frontend.allow_password_login = false;

            dav_push.enabled = true;
          };
        };

        services.caddy.virtualHosts.${self.globals.domains.cdav}.extraConfig = ''
          reverse_proxy http://localhost:${toString config.services.rustical.settings.http.port}
        '';
      };
    };
}
