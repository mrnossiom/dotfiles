{ config
, ...
}:

let
  warrior-port = 3015;
  warrior-hostname = "warrior.wiro.world";

  authelia-port = 3008;
in
{
  config = {
    virtualisation.oci-containers.containers.archive-warrior = {
      image = "atdr.meo.ws/archiveteam/warrior-dockerfile";
      ports = [ "127.0.0.1:${toString warrior-port}:8001" ];
      pull = "newer";
    };

    services.caddy = {
      virtualHosts.${warrior-hostname}.extraConfig = ''
        forward_auth localhost:${toString authelia-port} {
            uri /api/authz/forward-auth
        }
        reverse_proxy http://localhost:${toString warrior-port}
      '';
    };
  };
}
