{ config
, ...
}:

let
  thelounge-port = 3005;
  thelounge-hostname = "lounge.wiro.world";
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
      virtualHosts.${thelounge-hostname}.extraConfig = ''
        reverse_proxy http://localhost:${toString thelounge-port}
      '';
    };
  };
}
