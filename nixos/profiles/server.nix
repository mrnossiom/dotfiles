{ ...
}:

let
  ext-if = "eth0";

  external-ip6 = "2a01:4f8:c2c:76d2::1";
  external-netmask6 = 64;
  external-gw6 = "fe80::1";
in
{
  imports = [ ];

  config = {
    boot.loader.grub.enable = true;
    boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" "ext4" ];

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

      # # Rely on Hetzner firewall instead?
      # firewall.enable = false;
      firewall.allowedTCPPorts = [ 22 80 443 ];
    };

    services.openssh.enable = true;

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

      virtualHosts."ping.wiro.world".extraConfig = ''
      	header Content-Type text/html
      	respond <<HTML
      		<html>
      			<head><title>Foo</title></head>
      			<body>Foo</body>
      		</html>
      		HTML 200
      '';
    };

    security.sudo.wheelNeedsPassword = false;

    local.fragment.nix.enable = true;

    programs.fish.enable = true;
  };
}
