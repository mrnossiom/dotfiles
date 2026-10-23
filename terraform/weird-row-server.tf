resource "hcloud_server" "weird-row-server" {
  name        = "weird-row-server"
  server_type = "cx23"

  location = "nbg1"
  backups  = true

  public_net {
    ipv4 = hcloud_primary_ip.v4-nbg1-primary.id
    ipv6 = hcloud_primary_ip.v6-nbg1-primary.id
  }

  rebuild_protection = true
  delete_protection  = true
}
