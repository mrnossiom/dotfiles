{
  config,
  globals,
  ...
}:

{
  config = {
    local.ports.rustical = 3019;

    age.secrets.rustical-env.file = secrets/rustical-env.age;

    services.rustical = {
      enable = true;

      environmentFiles = [
        config.age.secrets.rustical-env.path
      ];

      settings = {
        http = {
          host = "[::]";
          port = config.local.ports.rustical.number;
        };

        oidc = {
          name = "Authelia";
          issuer = "https://${globals.domains.authelia}";
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

    services.caddy.virtualHosts.${globals.domains.cdav}.extraConfig = ''
      reverse_proxy http://localhost:${toString config.services.rustical.settings.http.port}
    '';

  };
}
