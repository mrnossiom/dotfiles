{ config
, ...
}:

let
  lldap-port = 3007;
  lldap-hostname = "ldap.net.wiro.world";
in
{
  config = {
    age.secrets.lldap-env.file = secrets/lldap-env.age;
    users.users.lldap = { isSystemUser = true; group = "lldap"; };
    users.groups.lldap = { };
    age.secrets.lldap-user-pass = { file = secrets/lldap-user-pass.age; owner = "lldap"; };
    services.lldap = {
      enable = true;

      silenceForceUserPassResetWarning = true;

      settings = {
        http_url = "https://${lldap-hostname}";
        http_port = lldap-port;

        ldap_user_pass_file = config.age.secrets.lldap-user-pass.path;
        force_ldap_user_pass_reset = false;

        ldap_base_dn = "dc=wiro,dc=world";
      };
      environmentFile = config.age.secrets.lldap-env.path;
    };

    services.caddy = {
      virtualHosts."http://${lldap-hostname}".extraConfig = ''
        bind tailscale/ldap
        reverse_proxy http://localhost:${toString config.services.lldap.settings.http_port}
      '';
    };
  };
}
