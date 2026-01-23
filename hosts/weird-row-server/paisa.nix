{
  config,
  pkgs,
  ...
}:

let
  # paisa-port = 3016;
  paisa-port = 7500;
in
{
  config = {
    services.paisa = {
      enable = true;
      port = paisa-port;
      host = "127.0.0.1";

      settings = { };
    };
    systemd.services.paisa.path = [ pkgs.hledger ];

    services.caddy = {
      virtualHosts."http://paisa.net.wiro.world".extraConfig = ''
        bind tailscale/paisa
        reverse_proxy http://localhost:${toString config.services.paisa.port}
      '';
    };
  };
}
