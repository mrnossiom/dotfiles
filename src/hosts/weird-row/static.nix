{ self, ... }:
{
  flake.modules.nixos.weird_row-static = { config, ... }: {
    config = {
      sops.secrets."storage_boxes/static" = { };
      sops.templates."storage_box_static.creds".content = ''
        username=u701292-sub1
        password=${config.sops.placeholder."storage_boxes/static"}
      '';

      services.hetzner.storageBoxes.static = {
        enable = true;
        username = "u701292-sub1";
        credentialsFile = config.sops.templates."storage_box_static.creds".path;
        owner = config.services.caddy.user;
      };

      services.caddy.virtualHosts.${self.globals.domains.static}.extraConfig = ''
        	handle /protected* {
           	forward_auth localhost:${config.local.ports.authelia.string} {
          		uri /api/authz/forward-auth
           	}

        		root * ${config.services.hetzner.storageBoxes.static.mountPoint}
        		file_server browse
        	}

        	handle /public* {
        		root * ${config.services.hetzner.storageBoxes.static.mountPoint}
        		file_server browse
        	}

        	handle {
        		root * ${config.services.hetzner.storageBoxes.static.mountPoint}
        		file_server
        	}
      '';
    };
  };
}
