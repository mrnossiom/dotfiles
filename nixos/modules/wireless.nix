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
    services.printing.enable = true;

    services.avahi = {
      enable = true;
      nssmdns = true;
      openFirewall = true;
    };
  };
}
