{ self
, config
, ...
}:

let
  inherit (self.inputs) tangled;

  tangled-owner = "did:plc:xhgrjm4mcx3p5h3y6eino6ti";
  tangled-knot-port = 3003;
  tangled-knot-hostname = "knot.wiro.world";
  tangled-spindle-port = 3004;
  tangled-spindle-hostname = "spindle.wiro.world";
in
{
  imports = [
    tangled.nixosModules.knot
    tangled.nixosModules.spindle
  ];

  config = {
    services.tangled.knot = {
      enable = true;
      openFirewall = true;

      motd = "Welcome to @wiro.world's knot!\n";
      server = {
        listenAddr = "localhost:${toString tangled-knot-port}";
        hostname = tangled-knot-hostname;
        owner = tangled-owner;
      };
    };

    services.tangled.spindle = {
      enable = true;

      server = {
        listenAddr = "localhost:${toString tangled-spindle-port}";
        hostname = tangled-spindle-hostname;
        owner = tangled-owner;
      };
    };

    services.caddy = {
      virtualHosts.${tangled-knot-hostname}.extraConfig = ''
        reverse_proxy http://localhost:${toString tangled-knot-port}
      '';

      virtualHosts.${tangled-spindle-hostname}.extraConfig = ''
        reverse_proxy http://localhost:${toString tangled-spindle-port}
      '';
    };
  };
}
