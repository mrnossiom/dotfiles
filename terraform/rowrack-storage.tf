variable "rowrack_storage_primary_password" {
  sensitive = true
}


resource "hcloud_storage_box" "rowrack-storage" {
  name             = "rowrack-storage"
  storage_box_type = "bx11"
  location         = "fsn1"

  password = var.rowrack_storage_primary_password

  access_settings = {
    samba_enabled        = true
    webdav_enabled       = false
    ssh_enabled          = false
    reachable_externally = false
    zfs_enabled          = false # show snapshots folder
  }

  snapshot_plan = {
    hour          = 5
    minute        = 00
    max_snapshots = 10
  }

  delete_protection = true
}

# variable "rowrack_storage_password" {
#   sensitive = true
# }

# resource "hcloud_storage_box_subaccount" "backups" {
#   storage_box_id = hcloud_storage_box.rowrack-storage.id

#   name           = "backups"
#   home_directory = "backups"

#   access_settings = {
#     samba_enabled        = true
#     reachable_externally = true
#   }
# }

# TODO: add public bucket with Caddy proxy to serve the files
