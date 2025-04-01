{
  nixos = {
    backup-rclone-googledrive.file = ./backup/rclone-googledrive.age;
    backup-restic-key.file = ./backup/restic-key.age;
  };

  home-manager = {
    api-crates-io.file = ./api-crates-io.age;
    api-digital-ocean.file = ./api-digital-ocean.age;
    api-gitguardian.file = ./api-gitguardian.age;
    api-wakatime.file = ./api-wakatime.age;
  };

  deploy = {
    pds-config.file = ./pds-env.age;
  };

  none = {
    pgp-ca5e.file = ./pgp-ca5e.age;
    ssh-uxgi.file = ./ssh-uxgi.age;
  };
}
