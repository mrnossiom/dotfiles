let
  archaic = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHLLJ+6UiJYTD0HhWwTBom5fmZ4RaCXAUgcGaXgfdG8S";

  # Password protected keys 
  neo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJdt7atyPTOfaBIsgDYYb0DG1yid2u78abaCDji6Uxgi";

  systems = [ archaic neo ];
in
{
  "ca5e.pgp.age".publicKeys = systems;
  "digital-ocean.api.age".publicKeys = systems;
  "gitguardian.api.age".publicKeys = systems;
  "googledrive.rclone.conf.age".publicKeys = systems;
  "restic-backup-pass.age".publicKeys = systems;
}
