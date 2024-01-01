{ lib
, config
, pkgs
, ...
}:

with lib;

{
  config = {
    # Wifi
    networking.networkmanager.enable = true;
    networking.nameservers = [ "1.1.1.1" "8.8.8.8" "9.9.9.9" ];

    programs.nm-applet.enable = true;

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
