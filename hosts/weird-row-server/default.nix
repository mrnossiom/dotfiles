{ self
, config
, pkgs
, ...
}:

let
  inherit (self.inputs) srvos;

  ext-if = "eth0";
  external-ip = "91.99.55.74";
  external-netmask = 27;
  external-gw = "144.x.x.255";
  external-ip6 = "2a01:4f8:c2c:76d2::1";
  external-netmask6 = 64;
  external-gw6 = "fe80::1";

  website-hostname = "wiro.world";

  static-hostname = "static.wiro.world";
in
{
  imports = [
    srvos.nixosModules.server
    srvos.nixosModules.hardware-hetzner-cloud
    srvos.nixosModules.mixins-terminfo

    ./authelia.nix
    ./goatcounter.nix
    ./grafana.nix
    ./headscale.nix
    ./hypixel-bank-tracker.nix
    ./lldap.nix
    ./miniflux.nix
    ./pds.nix
    ./tangled.nix
    ./thelounge.nix
    ./tuwunel.nix
    ./vaultwarden.nix
    ./warrior.nix
    ./webfinger.nix
  ];

  config = {
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

      # Reflect firewall configuration on Hetzner
      firewall.allowedTCPPorts = [ 22 80 443 ];
    };

    services.qemuGuest.enable = true;

    services.openssh.enable = true;

    # age.secrets.tailscale-authkey.file = secrets/tailscale-authkey.age;
    services.tailscale = {
      enable = true;
      extraSetFlags = [ "--advertise-exit-node" ];
      # authKeyFile = config.age.secrets.tailscale-authkey.path;
      authKeyParameters = {
        baseURL = "https://headscale.wiro.world";
        ephemeral = true;
        preauthorized = true;
      };
    };

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

    age.secrets.caddy-env.file = secrets/caddy-env.age;
    services.caddy = {
      enable = true;
      package = pkgs.caddy.withPlugins {
        plugins = [
          "github.com/caddy-dns/hetzner/v2@v2.0.0-preview-1"
          "github.com/tailscale/caddy-tailscale@v0.0.0-20251016213337-01d084e119cb"
        ];
        hash = "sha256-muKwDYs5Jp4ib/psZxpp1Kyfsqz6wPz/lpHFGtx67uY=";
      };

      environmentFile = config.age.secrets.caddy-env.path;

      globalConfig = ''
        tailscale {
          # this caddy instance already proxies headscale but needs to access headscale to start
          # control_url https://headscale.wiro.world
          control_url http://localhost:3006

          ephemeral
        }
      '';

      virtualHosts.${website-hostname}.extraConfig =
        # TODO: host website on server with automatic deployment
        ''
          reverse_proxy https://mrnossiom.github.io {
          	header_up Host {http.request.host}
          }
        '';

      virtualHosts.${static-hostname}.extraConfig = ''
        root /var/www/static
        file_server browse
      '';
    };

    # TODO: use bind to declare dns records declaratively
  };
}
