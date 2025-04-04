let
  inherit (import ./keys.nix) servers sessions systems users;

  nixos = systems ++ users;
  home-manager = sessions ++ users;
  deploy = servers ++ users;
in
{
  # Used in NixOS config
  "backup/rclone-googledrive.age".publicKeys = nixos;
  "backup/restic-key.age".publicKeys = nixos;

  # Used in Home Manager
  "api-crates-io.age".publicKeys = home-manager;
  "api-digital-ocean.age".publicKeys = home-manager;
  "api-gitguardian.age".publicKeys = home-manager;
  "api-wakatime.age".publicKeys = home-manager;

  "pds-env.age".publicKeys = deploy;
  "tangled-env.age".publicKeys = deploy;

  # Not used in config but useful
  "pgp-ca5e.age".publicKeys = users;
  "ssh-uxgi.age".publicKeys = users;
}
