{ self, ... }:
{
  flake.modules.nixos.weird_row-slskd = { config, ... }: {
    local.ports.slskd = 3022;

    users.groups.media = { };

    sops.secrets."slskd/username" = { };
    sops.secrets."slskd/password" = { };
    sops.templates."slskd.env".content = ''
      SLSKD_USERNAME=${config.sops.placeholder."slskd/username"}
      SLSKD_PASSWORD=${config.sops.placeholder."slskd/password"}
      SLSKD_SLSK_USERNAME=${config.sops.placeholder."slskd/username"}
      SLSKD_SLSK_PASSWORD=${config.sops.placeholder."slskd/password"}
    '';

    services.slskd = {
      enable = true;
      openFirewall = true;

      group = "media";

      environmentFile = config.sops.templates."slskd.env".path;

      settings = {
        web.port = config.local.ports.slskd.number;

        directories.downloads = "${config.services.hetzner.storageBoxes.music.mountPoint}/AAA_To_Sort";
        shares.directories = [ config.services.hetzner.storageBoxes.music.mountPoint ];
      };
    };

    local.tailscale.net.binds.slskd = {
      enable = true;
      domain = self.globals.domains.slskd;
      port = config.local.ports.slskd.number;
    };
  };
}
