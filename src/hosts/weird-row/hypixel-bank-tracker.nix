{ self, inputs, ... }:
{
  flake.modules.nixos.weird_row-hypixel-bank-tracker = { config, ... }: {
    imports = [ inputs.hypixel-bank-tracker.nixosModules.default ];

    config = {
      local.ports.hbt-main = 3013;
      local.ports.hbt-banana = 3014;

      sops.secrets."hypixel_bank_tracker/hypixel_api_key" = { };
      sops.secrets."hypixel_bank_tracker/main_profile_uuid" = { };
      sops.secrets."hypixel_bank_tracker/banana_profile_uuid" = { };
      sops.templates."hbt-main.env".content = ''
        HBT_HYPIXEL_API_KEY=${config.sops.placeholder."hypixel_bank_tracker/hypixel_api_key"}
        HBT_PROFILE_UUID=${config.sops.placeholder."hypixel_bank_tracker/main_profile_uuid"}
      '';
      sops.templates."hbt-banana.env".content = ''
        HBT_HYPIXEL_API_KEY=${config.sops.placeholder."hypixel_bank_tracker/hypixel_api_key"}
        HBT_PROFILE_UUID=${config.sops.placeholder."hypixel_bank_tracker/banana_profile_uuid"}
      '';

      services.hypixel-bank-tracker.instances.main = {
        enable = true;
        port = config.local.ports.hbt-main.number;
        environmentFile = config.sops.templates."hbt-main.env".path;
      };

      services.hypixel-bank-tracker.instances.banana = {
        enable = true;
        port = config.local.ports.hbt-banana.number;
        environmentFile = config.sops.templates."hbt-banana.env".path;
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
