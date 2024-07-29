{ pkgs
, ...
}:

{
  config = {
    # Wifi
    networking.nameservers = [ "1.1.1.1" "8.8.8.8" "9.9.9.9" ];
    networking.networkmanager.enable = true;

    # Firewall
    networking.firewall = {
      enable = true;

      # TIP: Locally redirect ports with socat
      # socat tcp-listen:4242,reuseaddr,fork tcp:localhost:8000

      # Open arbitrary ports to share things on local networks
      allowedTCPPorts = [ 4242 ];
      allowedTCPPortRanges = [
        { from = 42420; to = 42429; }
      ];
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
