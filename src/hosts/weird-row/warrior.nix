{ self, ... }:
{
  flake.modules.nixos.weird_row-warrior = { config, ... }: {
    config = {
      local.ports.warrior = 3015;

      virtualisation.oci-containers.containers.archive-warrior = {
        image = "atdr.meo.ws/archiveteam/warrior-dockerfile";
        ports = [ "127.0.0.1:${config.local.ports.warrior.string}:8001" ];
        pull = "newer";

        environment = {
          DOWNLOADER = "wiro";
          SELECTED_PROJECT = "urls";
          CONCURRENT_ITEMS = "6";
        };
      };

      local.tailscale.net.binds.warrior = {
        enable = true;
        domain = self.globals.domains.warrior;
        port = config.local.ports.warrior.number;
      };
    };
  };
}
