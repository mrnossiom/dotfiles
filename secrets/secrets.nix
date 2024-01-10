let
  # Machine SSH key (/etc/ssh/ssh_host_ed25519_key.pub)
  archaic = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJDuBHC0f7N0q1KRczJMoaBVdY0JFOtcpPy6WlYsoxUh";
  neo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINR1/9o1HLnSRkXt3xxAM5So1YCCNdJpBN1leSu7giuR";
  systems = [ archaic neo ];

  # User keys 
  milomoisson = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJdt7atyPTOfaBIsgDYYb0DG1yid2u78abaCDji6Uxgi";
  users = [ milomoisson ];

  all = systems ++ users;
in
{
  "pgp-ca5e.age".publicKeys = all;
  "ssh-uxgi.age".publicKeys = all;

  # API Keys
  "api-digital-ocean.age".publicKeys = all;
  "api-gitguardian.age".publicKeys = all;

  # Backup
  "backup/rclone-googledrive.age".publicKeys = all;
  "backup/restic-key.age".publicKeys = all;
}
