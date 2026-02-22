{
  config,
  globals,
  ...
}:

{
  config = {
    local.ports.lldap-interface = 3007;
    local.ports.lldap-ldap = 3890;

    age.secrets.lldap-env.file = secrets/lldap-env.age;
    users.users.lldap = {
      isSystemUser = true;
      group = "lldap";
    };
    users.groups.lldap = { };
    age.secrets.lldap-user-pass = {
      file = secrets/lldap-user-pass.age;
      owner = "lldap";
    };
    services.lldap = {
      enable = true;

      silenceForceUserPassResetWarning = true;

      settings = {
        http_url = "https://${globals.domains.lldap}";
        http_port = config.local.ports.lldap-interface.number;

        ldap_user_pass_file = config.age.secrets.lldap-user-pass.path;
        force_ldap_user_pass_reset = false;

        ldap_base_dn = "dc=wiro,dc=world";
      };
      environmentFile = config.age.secrets.lldap-env.path;
    };

    services.caddy.virtualHosts.${globals.domains.lldap}.extraConfig = ''
      bind tailscale/ldap
      tls /var/lib/agnos/net.wiro.world_fullchain.pem /var/lib/agnos/net.wiro.world_privkey.pem
      reverse_proxy http://localhost:${toString config.services.lldap.settings.http_port}
    '';
  };
}
