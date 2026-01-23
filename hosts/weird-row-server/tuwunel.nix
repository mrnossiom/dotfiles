{
  config,
  ...
}:

let
  matrix-port = 3009;
  matrix-hostname = "matrix.wiro.world";

  website-hostname = "wiro.world";
in
{
  config = {
    age.secrets.tuwunel-registration-tokens = {
      file = secrets/tuwunel-registration-tokens.age;
      owner = config.services.matrix-tuwunel.user;
    };
    services.matrix-tuwunel = {
      enable = true;

      settings.global = {
        address = [ "127.0.0.1" ];
        port = [ matrix-port ];

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
      virtualHosts.${matrix-hostname}.extraConfig = ''
        reverse_proxy /_matrix/* http://localhost:${toString matrix-port}
      '';

      virtualHosts.${website-hostname}.extraConfig = ''
        reverse_proxy /.well-known/matrix/* http://localhost:${toString matrix-port}
      '';
    };
  };
}
