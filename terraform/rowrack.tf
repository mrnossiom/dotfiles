resource "random_password" "rowrack_primary_password" {
  length           = 64
  override_special = "ÄÖÜäöüß^°!§$%/()=?+#-.,;:~*@{}_&"
}

resource "hcloud_storage_box" "rowrack" {
  name             = "rowrack"
  storage_box_type = "bx11"
  location         = "fsn1"

  password = random_password.rowrack_primary_password.result

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

resource "random_password" "rowrack_public_password" {
  length           = 64
  override_special = "ÄÖÜäöüß^°!§$%/()=?+#-.,;:~*@{}_&"
}

resource "hcloud_storage_box_subaccount" "rowrack_public" {
  storage_box_id = hcloud_storage_box.rowrack.id

  password = random_password.rowrack_public_password.result

  name           = "public"
  home_directory = "weird-row/public"

  access_settings = {
    samba_enabled = true
  }
}

resource "random_password" "rowrack_hedgedoc_password" {
  length           = 64
  override_special = "ÄÖÜäöüß^°!§$%/()=?+#-.,;:~*@{}_&"
}

resource "hcloud_storage_box_subaccount" "rowrack_hedgedoc" {
  storage_box_id = hcloud_storage_box.rowrack.id

  password = random_password.rowrack_hedgedoc_password.result

  name           = "hedgedoc"
  home_directory = "weird-row/hedgedoc"

  access_settings = {
    samba_enabled = true
  }
}

resource "random_password" "rowrack_music_password" {
  length           = 64
  override_special = "ÄÖÜäöüß^°!§$%/()=?+#-.,;:~*@{}_&"
}

resource "hcloud_storage_box_subaccount" "rowrack_music" {
  storage_box_id = hcloud_storage_box.rowrack.id

  password = random_password.rowrack_music_password.result

  name           = "music"
  home_directory = "music"

  access_settings = {
    samba_enabled = true
  }
}

resource "random_password" "rowrack_movies_password" {
  length           = 64
  override_special = "ÄÖÜäöüß^°!§$%/()=?+#-.,;:~*@{}_&"
}

resource "hcloud_storage_box_subaccount" "rowrack_movies" {
  storage_box_id = hcloud_storage_box.rowrack.id

  password = random_password.rowrack_movies_password.result

  name           = "movies"
  home_directory = "movies"

  access_settings = {
    samba_enabled = true
  }
}

resource "random_password" "rowrack_immich_password" {
  length           = 64
  override_special = "ÄÖÜäöüß^°!§$%/()=?+#-.,;:~*@{}_&"
}

resource "hcloud_storage_box_subaccount" "rowrack_immich" {
  storage_box_id = hcloud_storage_box.rowrack.id

  password = random_password.rowrack_immich_password.result

  name           = "immich"
  home_directory = "immich"

  access_settings = {
    samba_enabled = true
  }
}

resource "random_password" "rowrack_tangled_password" {
  length           = 64
  override_special = "ÄÖÜäöüß^°!§$%/()=?+#-.,;:~*@{}_&"
}

resource "hcloud_storage_box_subaccount" "rowrack_tangled" {
  storage_box_id = hcloud_storage_box.rowrack.id

  password = random_password.rowrack_tangled_password.result

  name           = "tangled"
  home_directory = "tangled"

  access_settings = {
    samba_enabled = true
  }
}
