{
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.local.fragment.wireless;
in
{
  options.local.fragment.wireless.enable = lib.mkEnableOption ''
    Virtualisation related
    - Docker
  '';

  config = lib.mkIf cfg.enable {
    # Wifi
    networking.nameservers = [
      "1.1.1.1"
      "8.8.8.8"
      "9.9.9.9"
    ];
    networking.networkmanager.enable = true;

    # Firewall
    networking.firewall = {
      enable = true;

      # TIP: locally redirect ports with socat
      # socat tcp-listen:4242,reuseaddr,fork tcp:localhost:8000

      # Open arbitrary ports to share things on local networks
      allowedTCPPorts = [ 4242 ];
      allowedTCPPortRanges = [
        {
          from = 42420;
          to = 42429;
        }
      ];
      allowedUDPPorts = [ 4242 ];
      allowedUDPPortRanges = [
        {
          from = 42420;
          to = 42429;
        }
      ];

      # Allow packets from Docker containers
      # TODO: check if it actually works
      extraCommands = ''
        iptables -I INPUT 1 -s 172.16.0.0/12 -p tcp -d 172.17.0.1 -j ACCEPT
        iptables -I INPUT 2 -s 172.16.0.0/12 -p udp -d 172.17.0.1 -j ACCEPT
      '';
    };

    # Bluetooth
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;

    # Avahi is a service that takes care of advertising the current machine on
    # the network. AKA `Bonjour` in macOS lingua franca.
    services.avahi = {
      enable = true;

      nssmdns4 = true;
      openFirewall = true;

      # Advertise the machine, so we can be found as `<hostname>.local`
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
    };

    # Printing
    # Administration interface available at <http://localhost:631>
    services.printing = {
      enable = true;
      drivers = [ pkgs.hplipWithPlugin ];
    };
  };
}
