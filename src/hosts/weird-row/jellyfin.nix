{ self, ... }:
{
  flake.modules.nixos.weird_row-jellyfin = { config, ... }: {
    config = {
      local.ports.jellyfin = 8096;

      users.groups.media = { };

      sops.secrets."storage_boxes/music" = { };
      sops.templates."storage_box_music.creds".content = ''
        username=u701292-sub3
        password=${config.sops.placeholder."storage_boxes/music"}
      '';

      services.hetzner.storageBoxes.music = {
        enable = true;
        username = "u701292-sub3";
        credentialsFile = config.sops.templates."storage_box_music.creds".path;
        owner = config.services.jellyfin.user;
        group = "media";
      };

      sops.secrets."storage_boxes/movies" = { };
      sops.templates."storage_box_movies.creds".content = ''
        username=u701292-sub4
        password=${config.sops.placeholder."storage_boxes/movies"}
      '';

      services.hetzner.storageBoxes.movies = {
        enable = true;
        username = "u701292-sub4";
        credentialsFile = config.sops.templates."storage_box_movies.creds".path;
        owner = config.services.jellyfin.user;
      };

      services.jellyfin.enable = true;

      services.caddy.virtualHosts.${self.globals.domains.jellyfin}.extraConfig = ''
        reverse_proxy http://localhost:${config.local.ports.jellyfin.string}
      '';
    };
  };
}
