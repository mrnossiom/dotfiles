{
  config,
  pkgs,
  globals,
  ...
}:

{
  config = {
    local.ports.tailscale-exporter = 9005;

    # age.secrets.tailscale-authkey.file = secrets/tailscale-authkey.age;
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "server";
      extraSetFlags = [ "--advertise-exit-node" ];
      # authKeyFile = config.age.secrets.tailscale-authkey.path;
      authKeyParameters = {
        baseURL = "https://${globals.domains.headscale}";
        ephemeral = true;
        preauthorized = true;
      };
    };

    networking.nftables.enable = true;
    networking.firewall = {
      trustedInterfaces = [ config.services.tailscale.interfaceName ];
      allowedUDPPorts = [ config.services.tailscale.port ];
    };

    systemd.services.tailscaled.serviceConfig.Environment = [ "TS_DEBUG_FIREWALL_MODE=nftables" ];

    # services.networkd-dispatcher = {
    #   enable = true;
    #   rules."50-tailscale-optimizations" = {
    #     onState = [ "routable" ];
    #     script = ''
    #       ${pkgs.ethtool}/bin/ethtool -K eth0 rx-udp-gro-forwarding on rx-gro-list off
    #     '';
    #   };
    # };
  };
}
