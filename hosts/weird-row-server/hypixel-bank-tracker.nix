{ self
, config
, ...
}:

let
  inherit (self.inputs) hypixel-bank-tracker;

  hbt-main-port = 3013;
  hbt-banana-port = 3014;
in
{
  imports = [ hypixel-bank-tracker.nixosModules.default ];

  config = {
    age.secrets.hypixel-bank-tracker-main.file = secrets/hypixel-bank-tracker-main.age;
    services.hypixel-bank-tracker.instances.main = {
      enable = true;

      port = hbt-main-port;
      environmentFile = config.age.secrets.hypixel-bank-tracker-main.path;
    };

    age.secrets.hypixel-bank-tracker-banana.file = secrets/hypixel-bank-tracker-banana.age;
    services.hypixel-bank-tracker.instances.banana = {
      enable = true;

      port = hbt-banana-port;
      environmentFile = config.age.secrets.hypixel-bank-tracker-banana.path;
    };

    services.caddy = {
      virtualHosts."hypixel-bank-tracker.xyz".extraConfig = ''
        reverse_proxy http://localhost:${toString config.services.hypixel-bank-tracker.instances.main.port}
      '';

      virtualHosts."banana.hypixel-bank-tracker.xyz".extraConfig = ''
        reverse_proxy http://localhost:${toString config.services.hypixel-bank-tracker.instances.banana.port}
      '';
    };
  };
}
