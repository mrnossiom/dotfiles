{ config
, pkgs
, upkgs
, ...
}:

let
  ext-if = "en0";

  external-ip6 = "2a01:4f8:c2c:76d2::/64";
  external-netmask6 = 64;
  external-gw6 = "fe80::1";
in
{
  imports = [ ];

  config = {
    boot.loader.grub.device = "/dev/nvme0n1";

    # Single network card is `eth0`
    networking.usePredictableInterfaceNames = false;

    networking = {
      interfaces.${ext-if} = {
        ipv6.addresses = [{
          address = external-ip6;
          prefixLength = external-netmask6;
        }];
      };
      defaultGateway6 = {
        interface = ext-if;
        address = external-gw6;
      };
    };

    services.qemuGuest.enable = true;

    services.fail2ban = {
      enable = true;

      maxretry = 5;
      ignoreIP = [ ];

      bantime = "24h";
      bantime-increment = {
        enable = true;
        multipliers = "1 2 4 8 16 32 64";
        maxtime = "168h";
        overalljails = true;
      };

      jails = { };
    };

    # TODO: switch to nightly channel
    # services.pds = {
    #   enable = true;
    #   pdsadmin.enable = true;


    # };

    services.caddy = {
      enable = true;

      virtualHosts."localhost".extraConfig = ''
        reverse_proxy https://wirolibre.xyz/
      '';
    };

    programs.fish.enable = true;
  };
}

