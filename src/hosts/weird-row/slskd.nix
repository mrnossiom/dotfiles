{ self, ... }:
{
  flake.modules.nixos.weird_row-slskd = { config, ... }: {
    local.ports.slskd = 3022;

    age.secrets.slskd-env.file = ./secrets/slskd-env.age;

    users.groups.media = { };

    services.slskd = {
      enable = true;
      openFirewall = true;

      group = "media";

      environmentFile = config.age.secrets.slskd-env.path;

      settings = {
        web.port = config.local.ports.slskd.number;

        directories.downloads = "/mnt/music/AAA_To_Sort";
        shares.directories = [ "/mnt/music" ];
      };
    };

    local.tailscale.net.binds.slskd = {
      enable = true;
      domain = self.globals.domains.slskd;
      port = config.local.ports.slskd.number;
    };
  };
}
