{ self, ... }:
{
  flake.modules.nixos.weird_row-storage-box = { config, ... }: {
    imports = [ self.nixosModules.hetzner-storage-box ];

    config = {
      age.secrets.storage-box-creds-public.file = secrets/storage-box-creds-public.age;

      services.hetzner.storageBoxes.public = {
        enable = true;
        username = "u701292-sub1";
        share = "u701292-sub1";
        credentialsFile = config.age.secrets.storage-box-creds-public.path;
        mountPoint = "/mnt/public";
        owner = config.services.caddy.user;
      };

      services.caddy.virtualHosts.${self.globals.domains.public}.extraConfig = ''
        	root /mnt/public
         	file_server
      '';
    };
  };
}
