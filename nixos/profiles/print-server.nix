{ self
, config
, upkgs
, ...
}:

let
  inherit (self.inputs) srvos agenix tangled;

  all-secrets = import ../../secrets;

  ext-if = "eth0";
  external-ip = "91.99.55.74";
  external-netmask = 27;
  external-gw = "144.x.x.255";
  external-ip6 = "2a01:4f8:c2c:76d2::1";
  external-netmask6 = 64;
  external-gw6 = "fe80::1";

  octoprint-hostname = "print.wiro.world";
  octoprint-port = 3000;
in
{
  imports = [
    srvos.nixosModules.server
    srvos.nixosModules.hardware-hetzner-cloud
    srvos.nixosModules.mixins-terminfo

    agenix.nixosModules.default

    tangled.nixosModules.knotserver
  ];

  config = {
    age.secrets = all-secrets.deploy;

    boot.loader.grub.enable = true;
    boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" "ext4" ];

    # Single network card is `eth0`
    networking.usePredictableInterfaceNames = false;

    networking.nameservers = [ "2001:4860:4860::8888" "2001:4860:4860::8844" ];

    networking = {
      interfaces.${ext-if} = {
        ipv4.addresses = [{ address = external-ip; prefixLength = external-netmask; }];
        ipv6.addresses = [{ address = external-ip6; prefixLength = external-netmask6; }];
      };
      defaultGateway = { interface = ext-if; address = external-gw; };
      defaultGateway6 = { interface = ext-if; address = external-gw6; };

      firewall.allowedTCPPorts = [ 22 80 443 ];
    };

    services.openssh.enable = true;

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

    services.caddy = {
      enable = true;
      package = upkgs.caddy;

      globalConfig = ''
        metrics { per_host }
      '';

      virtualHosts.${octoprint-hostname}.extraConfig = ''
        reverse_proxy http://localhost:${toString octoprint-port}
      '';
    };

    services.octoprint = {
      enable = true;
      host = octoprint-hostname;
      port = octoprint-port;
    };

    security.sudo.wheelNeedsPassword = false;

    local.fragment.nix.enable = true;

    programs.fish.enable = true;
  };
}
