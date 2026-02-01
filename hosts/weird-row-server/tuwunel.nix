{
  config,
  globals,
  ...
}:

{
  config = {
    local.ports.matrix = 3009;

    age.secrets.tuwunel-registration-tokens = {
      file = secrets/tuwunel-registration-tokens.age;
      owner = config.services.matrix-tuwunel.user;
    };
    services.matrix-tuwunel = {
      enable = true;

      settings.global = {
        address = [ "127.0.0.1" ];
        port = [ config.local.ports.matrix.number ];

        server_name = "wiro.world";
        well_known = {
          client = "https://matrix.wiro.world";
          server = "matrix.wiro.world:443";
        };

        grant_admin_to_first_user = true;
        new_user_displayname_suffix = "";

        allow_registration = true;
        registration_token_file = config.age.secrets.tuwunel-registration-tokens.path;
      };
    };

    services.caddy = {
      virtualHosts.${globals.domains.matrix}.extraConfig = ''
        reverse_proxy /_matrix/* http://localhost:${config.local.ports.matrix.string}
      '';

      virtualHosts.${globals.domains.website}.extraConfig = ''
        reverse_proxy /.well-known/matrix/* http://localhost:${config.local.ports.matrix.string}
      '';
    };
  };
}
