keys:

let
  inherit (keys) sessions systems users;

  nixos = systems ++ users;
  home-manager = sessions ++ users;
in
{
  # Used in NixOS config
  "backup-rclone-googledrive.age".publicKeys = nixos;
  "backup-restic-key.age".publicKeys = nixos;

  # Used in Home Manager
  "api-crates-io.age".publicKeys = home-manager;
  "api-wakatime.age".publicKeys = home-manager;
  "api-wakapi.age".publicKeys = home-manager;

  # Not used in config but useful
  "pgp-ca5e.age".publicKeys = users;
  "ssh-uxgi.age".publicKeys = users;
}
