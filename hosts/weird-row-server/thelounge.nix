{ config
, ...
}:

let
  thelounge-port = 3005;
  thelounge-hostname = "irc-lounge.net.wiro.world";
in
{
  config = {
    services.thelounge = {
      enable = true;
      port = thelounge-port;
      public = false;

      extraConfig = {
        host = "127.0.0.1";
        reverseProxy = true;

        # TODO: use ldap, find a way to hide password
      };
    };

    services.caddy = {
      virtualHosts."http://${thelounge-hostname}".extraConfig = ''
        bind tailscale/irc-lounge
        reverse_proxy http://localhost:${toString config.services.thelounge.port}
      '';
    };
  };
}
