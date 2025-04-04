{ self
, config
, upkgs
, ...
}:

let
  inherit (self.inputs) srvos nixpkgs-unstable agenix;

  all-secrets = import ../../secrets;

  ext-if = "eth0";
  external-ip = "91.99.55.74";
  external-netmask = 27;
  external-gw = "144.x.x.255";
  external-ip6 = "2a01:4f8:c2c:76d2::1";
  external-netmask6 = 64;
  external-gw6 = "fe80::1";

  pds-port = 3001;
  pds-hostname = "pds.wiro.world";
in
{
  imports = [
    srvos.nixosModules.server
    srvos.nixosModules.hardware-hetzner-cloud
    srvos.nixosModules.mixins-terminfo

    agenix.nixosModules.default

    "${nixpkgs-unstable}/nixos/modules/services/web-apps/pds.nix"
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

      # TODO: rely on Hetzner firewall instead?
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
    services.pds = {
      enable = true;
      # TODO: not possible with current unstable module import
      pdsadmin.enable = false;
      package = upkgs.pds;

      settings = {
        PDS_HOSTNAME = "pds.wiro.world";
        PDS_PORT = pds-port;
        LOG_DESTINATION = "/etc/pds.log";
      };

      environmentFiles = [
        config.age.secrets.pds-config.path
      ];
    };

    services.caddy = {
      enable = true;

      globalConfig = ''
        on_demand_tls {
          ask http://localhost:${toString pds-port}/tls-check
        }
      '';

      virtualHosts."ping.wiro.world".extraConfig = ''
        	respond "Hello, World! (from `weird-row-server`)"
      '';

      virtualHosts."${pds-hostname}" = {
        serverAliases = [ "*.${pds-hostname}" ];
        extraConfig = ''
          	tls { on_demand }
            reverse_proxy http://localhost:${toString pds-port}
        '';
      };
    };

    security.sudo.wheelNeedsPassword = false;

    local.fragment.nix.enable = true;

    programs.fish.enable = true;
  };
}
