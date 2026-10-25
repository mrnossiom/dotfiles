{ self, inputs, ... }:
let
  tangled-owner = "did:plc:xhgrjm4mcx3p5h3y6eino6ti";
in
{
  flake.modules.nixos.weird_row_server-tangled = { config, ... }: {
    imports = [
      inputs.tangled.nixosModules.knot
      inputs.tangled.nixosModules.spindle
    ];

    config = {
      local.ports.tangled-knot = 3003;

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

      services.caddy.virtualHosts.${self.globals.domains.tangled-knot}.extraConfig = ''
        reverse_proxy http://localhost:${config.local.ports.tangled-knot.string}
      '';
    };
  };
}
