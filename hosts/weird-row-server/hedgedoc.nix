{
  config,
  globals,
  ...
}:

{
  config = {
    local.ports.hedgedoc = 3021;

    age.secrets.hedgedoc-env.file = secrets/hedgedoc-env.age;

    services.hedgedoc = {
      enable = true;

      environmentFile = config.age.secrets.hedgedoc-env.path;

      settings = {
        domain = "hedgedoc.wiro.world";
        port = config.local.ports.hedgedoc.number;

        protocolUseSSL = true;
        allowOrigin = [
          "localhost"
          "hedgedoc.example.com"
        ];

        email = false;
        allowAnonymous = false;
        allowFreeURL = true;
        defaultPermission = "private";

        oauth2 = {
          # sessionSecret = ...; # defined in the env

          providerName = "Authelia";
          authorizationURL = "https://${globals.domains.authelia}/api/oidc/authorization";
          tokenURL = "https://${globals.domains.authelia}/api/oidc/token";
          userProfileURL = "https://${globals.domains.authelia}/api/oidc/userinfo";

          clientID = "hedgedoc";
          # clientSecret = ...; # defined in `CMD_OAUTH2_CLIENT_SECRET`
          pkce = true;

          scope = "openid email profile groups";
          userProfileUsernameAttr = "preferred_username";
          userProfileDisplayNameAttr = "name";
          userProfileEmailAttr = "email";
        };
      };
    };

    services.caddy.virtualHosts.${globals.domains.hedgedoc}.extraConfig = ''
      reverse_proxy http://localhost:${toString config.services.hedgedoc.settings.port}
    '';
  };
}
