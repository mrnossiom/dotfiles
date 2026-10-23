resource "hcloud_server" "rowrack-server" {
  name        = "rowrack-server"
  server_type = "cx23"

  location = "fsn1"
  backups  = false

  public_net {
    ipv4 = hcloud_primary_ip.v4-fsn1-primary.id
    ipv6 = hcloud_primary_ip.v6-fsn1-primary.id
  }

  rebuild_protection = true
  delete_protection  = true
}
