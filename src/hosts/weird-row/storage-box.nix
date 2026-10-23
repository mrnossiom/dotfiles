{ self, ... }:
{
  flake.modules.nixos.weird_row-storage-box = { config, ... }: {
    imports = [ self.nixosModules.hetzner-storage-box ];

    config = {
      sops.secrets."storage_boxes/public" = { };
      sops.templates."storage_box_public.creds".content = ''
        username=u701292-sub1
        password=${config.sops.placeholder."storage_boxes/public"}
      '';

      services.hetzner.storageBoxes.public = {
        enable = true;
        username = "u701292-sub1";
        credentialsFile = config.sops.templates."storage_box_public.creds".path;
        owner = config.services.caddy.user;
      };

      services.caddy.virtualHosts.${self.globals.domains.public}.extraConfig = ''
        	root ${config.services.hetzner.storageBoxes.public.mountPoint}
         	file_server
      '';
    };
  };
}
