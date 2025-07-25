{ self
, config
, pkgs
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

  pds-port = 3001;
  pds-hostname = "pds.wiro.world";

  tangled-knot-port = 3002;
  tangled-knot-hostname = "knot.wiro.world";

  tangled-spindle-port = 3003;
  tangled-spindle-hostname = "spindle.wiro.world";

  grafana-port = 9000;
  grafana-hostname = "console.wiro.world";
  prometheus-port = 9001;
  prometheus-node-exporter-port = 9002;
in
{
  imports = [
    srvos.nixosModules.server
    srvos.nixosModules.hardware-hetzner-cloud
    srvos.nixosModules.mixins-terminfo

    agenix.nixosModules.default

    tangled.nixosModules.knot
    tangled.nixosModules.spindle
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

    services.tailscale.enable = true;

    services.pds = {
      enable = true;

      settings = {
        PDS_HOSTNAME = "pds.wiro.world";
        PDS_PORT = pds-port;
        # is in systemd /tmp subfolder
        LOG_DESTINATION = "/tmp/pds.log";
      };

      environmentFiles = [
        config.age.secrets.pds-config.path
      ];
    };

    services.caddy = {
      enable = true;
      package = pkgs.caddy;

      globalConfig = ''
        metrics { per_host }

        on_demand_tls {
          ask http://localhost:${toString pds-port}/tls-check
        }
      '';

      # Grafana has its own auth
      virtualHosts.${grafana-hostname}.extraConfig = ''
        reverse_proxy http://localhost:${toString grafana-port}
      '';

      virtualHosts.${pds-hostname} = {
        serverAliases = [ "*.${pds-hostname}" ];
        extraConfig = ''
          	tls { on_demand }
            reverse_proxy http://localhost:${toString pds-port}
        '';
      };

      virtualHosts.${tangled-knot-hostname}.extraConfig = ''
        reverse_proxy http://localhost:${toString tangled-knot-port}
      '';

      virtualHosts.${tangled-spindle-hostname}.extraConfig = ''
        reverse_proxy http://localhost:${toString tangled-spindle-port}
      '';
    };

    security.sudo.wheelNeedsPassword = false;

    local.fragment.nix.enable = true;

    programs.fish.enable = true;

    services.tangled-knot = {
      enable = true;
      openFirewall = true;

      server = {
        listenAddr = "localhost:${toString tangled-knot-port}";
        secretFile = config.age.secrets.tangled-config.path;
        hostname = tangled-knot-hostname;
      };
    };


    services.tangled-spindle = {
      enable = true;

      server = {
        listenAddr = "localhost:${toString tangled-spindle-port}";
        hostname = tangled-spindle-hostname;
        owner = "did:plc:xhgrjm4mcx3p5h3y6eino6ti";
      };
    };

    services.grafana = {
      enable = true;

      settings.server = {
        http_port = grafana-port;
        domain = grafana-hostname;
      };
    };

    services.prometheus = {
      enable = true;
      port = prometheus-port;

      scrapeConfigs = [
        {
          job_name = "caddy";
          static_configs = [{ targets = [ "localhost:${toString 2019}" ]; }];
        }
        {
          job_name = "node";
          static_configs = [{ targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ]; }];
        }
      ];

      exporters.node = {
        enable = true;
        port = prometheus-node-exporter-port;
      };
    };
  };
}
