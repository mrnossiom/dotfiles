let
  old-neo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINUkJvLMjjzbZSrnucc2uQeRhiuXPiZXNjqT80PVSSQb";
  archaic = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHLLJ+6UiJYTD0HhWwTBom5fmZ4RaCXAUgcGaXgfdG8S";
  systems = [ old-neo archaic ];
in
{
  "CA5E-pgp-key.age".publicKeys = systems;
}
