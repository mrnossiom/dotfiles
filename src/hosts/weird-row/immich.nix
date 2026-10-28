{ self, ... }:
{
  flake.modules.nixos.weird_row-immich = { config, ... }: {
    config = {
      local.ports.immich = 3023;
      # this port is baked in the config, cannot change
      local.ports.immich-machine-learning = 3003;

      age.secrets.storage-box-creds-immich.file = secrets/storage-box-creds-immich.age;

      services.hetzner.storageBoxes.immich = {
        enable = true;
        username = "u701292-sub5";
        credentialsFile = config.age.secrets.storage-box-creds-immich.path;
        owner = config.services.immich.user;
      };

      services.immich = {
        enable = true;
        machine-learning.enable = true;

        port = config.local.ports.immich.number;
        mediaLocation = config.services.hetzner.storageBoxes.immich.mountPoint;

        settings = {
          newVersionCheck.enabled = false;
          server.externalDomain = "https://${self.globals.domains.immich}";
        };
      };

      services.caddy.virtualHosts.${self.globals.domains.immich}.extraConfig = ''
        reverse_proxy http://localhost:${config.local.ports.immich.string}
      '';
    };
  };
}
