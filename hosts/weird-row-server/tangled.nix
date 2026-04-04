{
  self,
  config,
  globals,
  ...
}:

let
  inherit (self.inputs) tangled;

  tangled-owner = "did:plc:xhgrjm4mcx3p5h3y6eino6ti";
in
{
  imports = [
    tangled.nixosModules.knot
    tangled.nixosModules.spindle
  ];

  config = {
    local.ports.tangled-knot = 3003;

    services.tangled.knot = {
      enable = true;
      openFirewall = true;

      motd = "Welcome to @wiro.world's knot!\n";
      server = {
        listenAddr = "localhost:${config.local.ports.tangled-knot.string}";
        hostname = globals.domains.tangled-knot;
        owner = tangled-owner;
      };
    };

    services.caddy.virtualHosts.${globals.domains.tangled-knot}.extraConfig = ''
      reverse_proxy http://localhost:${config.local.ports.tangled-knot.string}
    '';
  };
}
