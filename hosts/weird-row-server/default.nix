{
  self,
  globals,
  ...
}:

let
  inherit (self.inputs) srvos;
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

    networking.nameservers = [
      "2001:4860:4860::8888"
      "2001:4860:4860::8844"
    ];
    
    # Single network card is `eth0`
    networking.usePredictableInterfaceNames = false;

    systemd.network.networks."40-eth0" = {
      matchConfig.Name = "eth0";
      address = [
        "${globals.hosts.weird-row-server.ip}/${toString globals.hosts.weird-row-server.ip-prefix-length}"
        "${globals.hosts.weird-row-server.ip6}/${toString globals.hosts.weird-row-server.ip6-prefix-length}"
        "${globals.hosts.weird-row-server.ip6-agnos}/${toString globals.hosts.weird-row-server.ip6-prefix-length}"
      ];
      routes = [
        {
          Gateway = "172.31.1.1";
          GatewayOnLink = true;
        }
        { Gateway = "fe80::1"; }
      ];
      linkConfig.RequiredForOnline = "routable";
    };

    # wrote a file in /etc/systemd/networking/ that override networking.interfaces
    services.cloud-init.network.enable = false;

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
