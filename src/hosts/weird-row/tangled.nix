{ self, inputs, ... }:
let
  tangled-owner = "did:plc:xhgrjm4mcx3p5h3y6eino6ti";
in
{
  flake.modules.nixos.weird_row-tangled = { config, ... }: {
    imports = [
      inputs.tangled.nixosModules.knot
      inputs.tangled.nixosModules.spindle
    ];

    config = {
      local.ports.tangled-knot = 3003;

      age.secrets.tangled-knot2-env.file = secrets/tangled-knot2-env.age;

      services.tangled.knot = {
        enable = true;
        openFirewall = true;

        motd = "Welcome to @wiro.world's knot!\n";
        server = {
          listenAddr = "localhost:${config.local.ports.tangled-knot.string}";
          hostname = self.globals.domains.tangled-knot;
          owner = tangled-owner;
        };
      };

      # services.tangled.knot-rs = {
      #   enable = false;
      #   environmentFile = config.age.secrets.tangled-knot2-env.path;

      #   settings = {
      #     server = {
      #       hostname = "knot.wiro.world";
      #       admins = [ tangled-owner ];
      #       ssh_listen_addr = "[::]:2222";
      #     };
      #     atproto.plc_directory = "https://plc.directory";
      #     xrpc = {
      #       trusted_proxy_header = "x-forwarded-for";
      #       trusted_proxies = [
      #         "127.0.0.1"
      #         "::1"
      #       ];
      #     };
      #   };
      # };

      services.caddy.virtualHosts.${self.globals.domains.tangled-knot}.extraConfig = ''
        reverse_proxy http://localhost:${config.local.ports.tangled-knot.string}
      '';
    };
  };
}
