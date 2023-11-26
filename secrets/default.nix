{ ... }: {
  age.secrets = {
    ca5e-pgp.file = ./ca5e.pgp.age;
    digital-ocean-api-key.file = ./digital-ocean.api.age;
    gitguardian-api-key.file = ./gitguardian.api.age;
    googledrive-rclone-config.file = ./googledrive.rclone.conf.age;
    restic-backup-pass.file = ./restic-backup-pass.age;
  };
}
