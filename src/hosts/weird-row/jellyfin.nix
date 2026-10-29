{ self, ... }:
{
  flake.modules.nixos.weird_row-jellyfin = { config, ... }: {
    config = {
      local.ports.jellyfin = 8096;

      age.secrets.jellyfin-ldap-password.file = secrets/jellyfin-ldap-password.age;

      age.secrets.storage-box-creds-jellyfin-music.file = secrets/storage-box-creds-jellyfin-music.age;

      users.groups.media = { };

      services.hetzner.storageBoxes.music = {
        enable = true;
        username = "u701292-sub3";
        credentialsFile = config.age.secrets.storage-box-creds-jellyfin-music.path;
        owner = config.services.jellyfin.user;
        group = "media";
      };

      age.secrets.storage-box-creds-jellyfin-movies.file = secrets/storage-box-creds-jellyfin-movies.age;

      services.hetzner.storageBoxes.movies = {
        enable = true;
        username = "u701292-sub4";
        credentialsFile = config.age.secrets.storage-box-creds-jellyfin-movies.path;
        owner = config.services.jellyfin.user;
      };

      services.jellyfin = {
        enable = true;
      };

      services.caddy.virtualHosts.${self.globals.domains.jellyfin}.extraConfig = ''
        reverse_proxy http://localhost:${config.local.ports.jellyfin.string}
      '';
    };
  };
}
