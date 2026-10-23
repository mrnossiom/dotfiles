{ self, ... }:
{
  flake.modules.nixos.weird_row-lldap = { config, ... }: {
    config = {
      local.ports.lldap-interface = 3007;
      local.ports.lldap-ldap = 3890;

      users.users.lldap = {
        isSystemUser = true;
        group = "lldap";
      };
      users.groups.lldap = { };

      sops.secrets."lldap/jwt_secret" = { };
      sops.secrets."lldap/key_seed" = { };
      sops.templates."lldap.env".content = ''
        LLDAP_JWT_SECRET=${config.sops.placeholder."lldap/jwt_secret"}
        LLDAP_KEY_SEED=${config.sops.placeholder."lldap/key_seed"}
      '';

      sops.secrets."lldap/user_pass" = {
        owner = "lldap";
      };

      services.lldap = {
        enable = true;
        environmentFile = config.sops.templates."lldap.env".path;

        silenceForceUserPassResetWarning = true;

        settings = {
          http_url = "https://${self.globals.domains.lldap}";
          http_port = config.local.ports.lldap-interface.number;

          ldap_user_pass_file = config.sops.secrets."lldap/user_pass".path;
          force_ldap_user_pass_reset = false;

          ldap_base_dn = "dc=wiro,dc=world";
        };
      };

      local.tailscale.net.binds.ldap = {
        enable = true;
        domain = self.globals.domains.lldap;
        port = config.local.ports.lldap-interface.number;
      };
    };
  };
}
