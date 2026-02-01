{
  config,
  globals,
  ...
}:

{
  config = {
    local.ports.thelounge = 3005;

    services.thelounge = {
      enable = true;
      port = config.local.ports.thelounge.number;
      public = false;

      extraConfig = {
        host = "127.0.0.1";
        reverseProxy = true;

        # TODO: use ldap, find a way to hide password
      };
    };

    services.caddy = {
      virtualHosts."http://${globals.domains.thelounge}".extraConfig = ''
        bind tailscale/irc-lounge
        reverse_proxy http://localhost:${toString config.services.thelounge.port}
      '';
    };
  };
}
