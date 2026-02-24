{
  self,
  globals,
  ...
}:

let
  inherit (self.inputs) srvos;

  ext-if = "eth0";
  external-gateway = "144.x.x.255";
  external-gateway6 = "fe80::1";
in
{
  imports = [
    srvos.nixosModules.server
    srvos.nixosModules.hardware-hetzner-cloud
    srvos.nixosModules.mixins-terminfo

    ./agnos.nix
    ./authelia.nix
    ./caddy.nix
    ./gatus.nix
    ./goatcounter.nix
    ./grafana.nix
    ./headscale.nix
    ./hypixel-bank-tracker.nix
    ./lldap.nix
    ./miniflux.nix
    ./pds.nix
    ./ripe-atlas.nix
    ./tailscale.nix
    ./tangled.nix
    ./thelounge.nix
    ./tuwunel.nix
    ./vaultwarden.nix
    ./warrior.nix
    ./webfinger.nix

    # doesn't support domain restrictions
    # ./git-pages.nix
  ];

  config = {
    boot.loader.grub.enable = true;
    boot.initrd.availableKernelModules = [
      "ahci"
      "xhci_pci"
      "virtio_pci"
      "virtio_scsi"
      "sd_mod"
      "sr_mod"
      "ext4"
    ];

    networking = {
      # Single network card is `eth0`
      usePredictableInterfaceNames = false;

      nameservers = [
        "2001:4860:4860::8888"
        "2001:4860:4860::8844"
      ];

      interfaces.${ext-if} = {
        ipv4.addresses = [
          {
            address = globals.hosts.weird-row-server.ip;
            prefixLength = globals.hosts.weird-row-server.ip-prefix-length;
          }
        ];
        ipv6.addresses = [
          {
            address = globals.hosts.weird-row-server.ip6;
            prefixLength = globals.hosts.weird-row-server.ip6-prefix-length;
          }
          {
            address = globals.hosts.weird-row-server.ip6-agnos;
            prefixLength = globals.hosts.weird-row-server.ip6-prefix-length;
          }
        ];
      };
      defaultGateway = {
        interface = ext-if;
        address = external-gateway;
      };
      defaultGateway6 = {
        interface = ext-if;
        address = external-gateway6;
      };

    };

    services.qemuGuest.enable = true;

    local.ports.openssh = {
      number = 22;
      public = true;
    };
    services.openssh.enable = true;

    security.sudo.wheelNeedsPassword = false;

    local.fragment.nix.enable = true;

    programs.fish.enable = true;

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

    # TODO: use bind to declare dns records declaratively
  };
}
