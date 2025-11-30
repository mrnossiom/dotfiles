{ config
, ...
}:

let
  goatcounter-port = 3010;
  goatcounter-hostname = "stats.wiro.world";
in
{
  config = {
    services.goatcounter = {
      enable = true;

      port = goatcounter-port;
      proxy = true;
      extraArgs = [ "-automigrate" ];
    };

    services.caddy = {
      virtualHosts.${goatcounter-hostname}.extraConfig = ''
        reverse_proxy http://localhost:${toString goatcounter-port}
      '';
    };
  };
}
