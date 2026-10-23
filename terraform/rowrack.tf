resource "random_password" "storage_box_primary_password" {
  length           = 64
  override_special = "ÄÖÜäöüß^°!§$%/()=?+#-.,;:~*@{}_&"
}

output "rowrack-username" {
  value = hcloud_storage_box.rowrack.username
}

resource "hcloud_storage_box" "rowrack" {
  name             = "rowrack"
  storage_box_type = "bx11"
  location         = "fsn1"

  password = random_password.storage_box_primary_password.result

  access_settings = {
    samba_enabled        = true
    webdav_enabled       = false
    ssh_enabled          = false
    reachable_externally = true
    zfs_enabled          = false # show snapshots folder
  }

  snapshot_plan = {
    hour          = 5
    minute        = 00
    max_snapshots = 10
  }

  delete_protection = true
}

resource "random_password" "storage_box_public_password" {
  length           = 64
  override_special = "ÄÖÜäöüß^°!§$%/()=?+#-.,;:~*@{}_&"
}

resource "hcloud_storage_box_subaccount" "public" {
  storage_box_id = hcloud_storage_box.rowrack.id

  password = random_password.storage_box_public_password.result

  name           = "public"
  home_directory = "weird-row/public"

  access_settings = {
    samba_enabled = true
  }
}


  access_settings = {
    samba_enabled = true
  }
}
