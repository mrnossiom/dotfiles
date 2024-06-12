{ pkgs
, ...
}:

{
  config = {
    # Wifi
    networking.nameservers = [ "1.1.1.1" "8.8.8.8" "9.9.9.9" ];
    networking.networkmanager.enable = true;

    # Bluetooth
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;

    # Printing
    # Administration interface available at <http://localhost:631>

    services.printing = {
      enable = true;
      drivers = [ pkgs.hplipWithPlugin ];
    };

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
