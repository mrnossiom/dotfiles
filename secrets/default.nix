{
  nixos = {
    backup-rclone-googledrive.file = ./backup/rclone-googledrive.age;
    backup-restic-key.file = ./backup/restic-key.age;
  };

  home-manager = {
    api-digital-ocean.file = ./api-digital-ocean.age;
    api-gitguardian.file = ./api-gitguardian.age;
    api-wakatime.file = ./api-wakatime.age;
  };

  none = {
    pgp-ca5e.file = ./pgp-ca5e.age;
    ssh-uxgi.file = ./ssh-uxgi.age;
  };
}
