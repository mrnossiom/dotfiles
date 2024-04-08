let
  # Machine SSH key (/etc/ssh/ssh_host_ed25519_key.pub)
  archaic = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJDuBHC0f7N0q1KRczJMoaBVdY0JFOtcpPy6WlYsoxUh";
  neo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINR1/9o1HLnSRkXt3xxAM5So1YCCNdJpBN1leSu7giuR";
  systems = [ archaic neo ];

  # Sessions specific age key (~/.ssh/id_home_manager)
  neo-milomoisson = "age1vz2zmduaqhaw5jrqh277pmp36plyth8rz5k9ccxeftfcl2nlhalqwvx5xz";
  sessions = [ neo-milomoisson ];

  # User keys 
  milomoisson = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJdt7atyPTOfaBIsgDYYb0DG1yid2u78abaCDji6Uxgi";
  users = [ milomoisson ];

  nixos = systems ++ users;
  home-manager = sessions ++ users;
in
{
  # Used in NixOS config
  "backup/rclone-googledrive.age".publicKeys = nixos;
  "backup/restic-key.age".publicKeys = nixos;

  # Used in Home Manager
  "api-digital-ocean.age".publicKeys = home-manager;
  "api-gitguardian.age".publicKeys = home-manager;
  "api-wakatime.age".publicKeys = home-manager;

  # Not used in config but useful
  "pgp-ca5e.age".publicKeys = users;
  "ssh-uxgi.age".publicKeys = users;
}
