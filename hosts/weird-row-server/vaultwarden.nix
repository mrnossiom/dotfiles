{
  config,
  globals,
  ...
}:

{
  config = {
    local.ports.vaultwarden = 3011;

    age.secrets.vaultwarden-env.file = secrets/vaultwarden-env.age;
    services.vaultwarden = {
      enable = true;

      environmentFile = config.age.secrets.vaultwarden-env.path;
      config = {
        ROCKET_PORT = config.local.ports.vaultwarden.number;
        DOMAIN = "https://${globals.domains.vaultwarden}";
        SIGNUPS_ALLOWED = false;
        ADMIN_TOKEN = "$argon2id$v=19$m=65540,t=3,p=4$YIe9wmrTsmjgZNPxe8m34O/d3XW3Fl/uZPPLQs79dAc$mjDVQSdBJqz2uBJuxtAvCIoHPzOnTDhNPuhER3dhHrY";

        SMTP_HOST = "smtp.resend.com";
        SMTP_PORT = 2465;
        SMTP_SECURITY = "force_tls";
        SMTP_USERNAME = "resend";
        # SMTP_PASSWORD = ...; # via secret env
        SMTP_FROM = "vaultwarden@services.wiro.world";
        SMTP_FROM_NAME = "wiro.world Vaultwarden";

        SSO_ENABLED = true;
        SSO_ONLY = false; # we want to access the service even if SSO is down
        SSO_AUTHORITY = "https://${globals.domains.authelia}";
        SSO_SCOPES = "profile email offline_access";
        SSO_CLIENT_ID = "vaultwarden";
        # SSO_CLIENT_SECRET = ...; # via secret env
      };
    };

    services.caddy.virtualHosts.${globals.domains.vaultwarden}.extraConfig = ''
      reverse_proxy http://localhost:${toString config.services.vaultwarden.config.ROCKET_PORT}
    '';
  };
}
