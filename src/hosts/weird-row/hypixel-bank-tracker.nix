{ self, inputs, ... }:
{
  flake.modules.nixos.weird_row_server-hypixel-bank-tracker = { config, ... }: {
    imports = [ inputs.hypixel-bank-tracker.nixosModules.default ];

    config = {
      local.ports.hbt-main = 3013;
      local.ports.hbt-banana = 3014;

      age.secrets.hypixel-bank-tracker-main.file = secrets/hypixel-bank-tracker-main.age;
      services.hypixel-bank-tracker.instances.main = {
        enable = true;

        port = config.local.ports.hbt-main.number;
        environmentFile = config.age.secrets.hypixel-bank-tracker-main.path;
      };

      age.secrets.hypixel-bank-tracker-banana.file = secrets/hypixel-bank-tracker-banana.age;
      services.hypixel-bank-tracker.instances.banana = {
        enable = true;

        port = config.local.ports.hbt-banana.number;
        environmentFile = config.age.secrets.hypixel-bank-tracker-banana.path;
      };

      services.caddy = {
        virtualHosts.${self.globals.domains.hbt-main}.extraConfig = ''
          reverse_proxy http://localhost:${toString config.services.hypixel-bank-tracker.instances.main.port}
        '';

        virtualHosts.${self.globals.domains.hbt-banana}.extraConfig = ''
          reverse_proxy http://localhost:${toString config.services.hypixel-bank-tracker.instances.banana.port}
        '';
      };
    };
  };
}
