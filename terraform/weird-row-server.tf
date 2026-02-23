resource "hcloud_server" "weird-row-server" {
  name        = "weird-row-server"
  server_type = "cx23"

  image    = "ubuntu-20.04"
  location = "nbg1"
  backups  = true

  public_net {
    ipv4 = hcloud_primary_ip.primary-v4.id
    ipv6 = hcloud_primary_ip.primary-v6.id
  }

  rebuild_protection = true
  delete_protection  = true
}
