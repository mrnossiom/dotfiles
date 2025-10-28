let
  inherit (import ./keys.nix) servers sessions systems users;

  nixos = systems ++ users;
  home-manager = sessions ++ users;
  deploy = servers ++ users;
in
{
  # Used in NixOS config
  "backup-rclone-googledrive.age".publicKeys = nixos;
  "backup-restic-key.age".publicKeys = nixos;

  # Used in Home Manager
  "api-crates-io.age".publicKeys = home-manager;
  "api-wakatime.age".publicKeys = home-manager;
  "api-wakapi.age".publicKeys = home-manager;

  # Used in server deployment

  # Defines `PDS_JWT_SECRET`, `PDS_ADMIN_PASSWORD`, `PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX`, `PDS_EMAIL_SMTP_URL`, `PDS_EMAIL_FROM_ADDRESS`.
  "pds-env.age".publicKeys = deploy;
  # Defines `LLDAP_JWT_SECRET`, `LLDAP_KEY_SEED`.
  "lldap-env.age".publicKeys = deploy;

  # Not used in config but useful
  "pgp-ca5e.age".publicKeys = users;
  "ssh-uxgi.age".publicKeys = users;
}
