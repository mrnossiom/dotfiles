{ config
, ...
}:

let
  miniflux-port = 3012;
  miniflux-hostname = "news.wiro.world";
in
{
  config = {
    users.users.miniflux = { isSystemUser = true; group = "miniflux"; };
    users.groups.miniflux = { };
    age.secrets.miniflux-oidc-secret = { file = secrets/miniflux-oidc-secret.age; owner = "miniflux"; };
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

    services.prometheus.scrapeConfigs = [{
      job_name = "miniflux";
      static_configs = [{ targets = [ "localhost:${toString miniflux-port}" ]; }];
    }];

    services.caddy = {
      virtualHosts.${miniflux-hostname}.extraConfig = ''
        reverse_proxy http://localhost:${toString miniflux-port}
      '';
    };
  };
}
