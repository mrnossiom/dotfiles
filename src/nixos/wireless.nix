{
  flake.modules.nixos.wireless = { pkgs, ... }: {
    config = {
      # Wifi
      networking.networkmanager.enable = true;

      # DNS
      services.resolved = {
        enable = true;
        settings.Resolve = {
          DNS = [
            "49.12.222.213#hard.dnsforge.de"
            "88.198.122.154#hard.dnsforge.de"
            "2a01:4f8:c17:2c61::213#hard.dnsforge.de"
            "2a01:4f8:c013:5ec0::154#hard.dnsforge.de"
          ];
          DNSOverTLS = true;
          DNSSEC = true;
        };
      };

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
  };
}
