{ self, ... }:
{
  flake.modules.nixos.weird_row-hedgedoc = { config, ... }: {
    config = {
      local.ports.hedgedoc = 3021;

      age.secrets.storage-box-creds-hedgedoc.file = secrets/storage-box-creds-hedgedoc.age;

      users.users.hedgedoc.isSystemUser = true;
      users.users.hedgedoc.group = "hedgedoc";
      users.groups.hedgedoc = { };

      services.hetzner.storageBoxes.hedgedoc = {
        enable = true;
        username = "u701292-sub2";
        credentialsFile = config.age.secrets.storage-box-creds-hedgedoc.path;
        owner = config.users.users.hedgedoc.name;
      };

      age.secrets.hedgedoc-env.file = secrets/hedgedoc-env.age;

      services.hedgedoc = {
        enable = true;

        environmentFile = config.age.secrets.hedgedoc-env.path;

        settings = {
          domain = "hedgedoc.wiro.world";
          port = config.local.ports.hedgedoc.number;

          db = {
            dialect = "sqlite";
            storage = "/var/lib/hedgedoc/db.sqlite";
          };
          uploadsPath = "${config.services.hetzner.storageBoxes.hedgedoc.mountPoint}/uploads";

          protocolUseSSL = true;

          allowAnonymous = false; # disable guests note creation
          allowAnonymousEdits = true; # allow `freely` permission mode
          allowFreeURL = true; # allow creation of custom URLs notes
          defaultPermission = "private";

          email = false;
          oauth2 = {
            # sessionSecret = ...; # defined in the env

            providerName = "Authelia";
            authorizationURL = "https://${self.globals.domains.authelia}/api/oidc/authorization";
            tokenURL = "https://${self.globals.domains.authelia}/api/oidc/token";
            userProfileURL = "https://${self.globals.domains.authelia}/api/oidc/userinfo";

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

      services.caddy.virtualHosts.${self.globals.domains.hedgedoc}.extraConfig = ''
        reverse_proxy http://localhost:${toString config.services.hedgedoc.settings.port}
      '';
    };
  };
}
