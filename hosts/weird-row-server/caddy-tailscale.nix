{
  config,
  globals,
  ...
}:

{
  config = {
    containers.caddy-tailscale = {
      autoStart = true;
      privateNetwork = false;
      # hostAddress = "192.168.100.10";
      # localAddress = "192.168.100.11";

      bindMounts = {
        "/var/lib/agnos/".isReadOnly = true;
        "/run/agenix/".isReadOnly = true;
      };

      # forwardPorts =
      #   let
      #     mkFwd = port: {
      #       containerPort = port;
      #       hostPort = port;
      #       protocol = "tcp";
      #     };
      #   in
      #   [
      #     (mkFwd config.local.ports.grafana.number)
      #     (mkFwd config.local.ports.lldap-interface.number)
      #     (mkFwd config.local.ports.thelounge.number)
      #     (mkFwd config.local.ports.warrior.number)
      #   ];

      config =
        { pkgs, ... }:
        {
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

            virtualHosts.${globals.domains.thelounge}.extraConfig = ''
              bind tailscale/irc
              tls /var/lib/agnos/net.wiro.world_fullchain.pem /var/lib/agnos/net.wiro.world_privkey.pem
              reverse_proxy http://localhost:${config.local.ports.thelounge.string}
            '';

            virtualHosts.${globals.domains.warrior}.extraConfig = ''
              bind tailscale/warrior
              tls /var/lib/agnos/net.wiro.world_fullchain.pem /var/lib/agnos/net.wiro.world_privkey.pem
              reverse_proxy http://localhost:${config.local.ports.warrior.string}
            '';
          };

          # networking.firewall.allowedTCPPorts = [
          #   config.local.ports.grafana.number
          #   config.local.ports.lldap-interface.number
          #   config.local.ports.thelounge.number
          #   config.local.ports.warrior.number
          # ];

          system.stateVersion = "26.05";
        };
    };
  };
}
