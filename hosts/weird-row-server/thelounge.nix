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
      virtualHosts.${globals.domains.thelounge}.extraConfig = ''
        bind tailscale/irc-lounge
        tls /var/lib/agnos/net.wiro.world_fullchain.pem /var/lib/agnos/net.wiro.world_privkey.pem
        reverse_proxy http://localhost:${toString config.services.thelounge.port}
      '';
    };
  };
}
