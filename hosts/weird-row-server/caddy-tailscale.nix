{
  config,
  globals,
  ...
}:

# We need a second caddy instance to support the tailscale plugin.
# Else we have a dep cycle of authelia -> caddy -> tailscale → authelia
# A light container is the simplest way to configure it.

{
  config = {
    containers.caddy-tailscale = {
      autoStart = true;
      privateNetwork = false;

      bindMounts = {
        "/var/lib/agnos/".isReadOnly = true;
        "/run/agenix/".isReadOnly = true;
      };

      config =
        { pkgs, ... }:
        {
          system.stateVersion = "26.05";

          # used to link the "host-agnos" group in the container to the host "agnos" group
          # needed to read the certs
          users.groups.host-agnos.gid = 980;
          users.users.caddy.extraGroups = [ "host-agnos" ];

          services.caddy = {
            enable = true;
            package = pkgs.caddy.withPlugins {
              plugins = [
                "github.com/tailscale/caddy-tailscale@v0.0.0-20251016213337-01d084e119cb"
              ];
              hash = "sha256-3wQi0f6hR1TDdL0hXHzHaZPPNLOMiu6jW76YYAvMXBU=";
            };

            environmentFile = config.age.secrets.caddy-env.path;

            globalConfig = ''
              auto_https off
              admin localhost:2020

              tailscale {
                control_url https://headscale.wiro.world
                ephemeral
              }
            '';

            virtualHosts.${globals.domains.grafana}.extraConfig = ''
              bind tailscale/console
              tls /var/lib/agnos/net.wiro.world_fullchain.pem /var/lib/agnos/net.wiro.world_privkey.pem
              reverse_proxy http://localhost:${config.local.ports.grafana.string}
            '';

            virtualHosts.${globals.domains.lldap}.extraConfig = ''
              bind tailscale/ldap
              tls /var/lib/agnos/net.wiro.world_fullchain.pem /var/lib/agnos/net.wiro.world_privkey.pem
              reverse_proxy http://localhost:${config.local.ports.lldap-interface.string}
            '';

            virtualHosts.${globals.domains.warrior}.extraConfig = ''
              bind tailscale/warrior
              tls /var/lib/agnos/net.wiro.world_fullchain.pem /var/lib/agnos/net.wiro.world_privkey.pem
              reverse_proxy http://localhost:${config.local.ports.warrior.string}
            '';
          };
        };
    };
  };
}
