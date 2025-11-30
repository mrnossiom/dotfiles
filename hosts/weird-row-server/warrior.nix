{ config
, ...
}:

let
  warrior-port = 3015;
  warrior-hostname = "warrior.net.wiro.world";
in
{
  config = {
    virtualisation.oci-containers.containers.archive-warrior = {
      image = "atdr.meo.ws/archiveteam/warrior-dockerfile";
      ports = [ "127.0.0.1:${toString warrior-port}:8001" ];
      pull = "newer";
    };

    services.caddy = {
      virtualHosts."http://${warrior-hostname}".extraConfig = ''
        bind tailscale/warrior
        reverse_proxy http://localhost:${toString warrior-port}
      '';
    };
  };
}
