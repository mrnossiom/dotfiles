terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.70"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.9.1"
    }
  }
}

variable "hcloud_token" {
  sensitive = true
}

provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_primary_ip" "v4-nbg1-primary" {
  name     = "v4-nbg1-primary"
  location = "nbg1"
  type     = "ipv4"

  auto_delete       = false
  delete_protection = true
}

resource "hcloud_primary_ip" "v6-nbg1-primary" {
  name     = "v6-nbg1-primary"
  location = "nbg1"
  type     = "ipv6"

  auto_delete       = false
  delete_protection = true
}

resource "hcloud_primary_ip" "v4-fsn1-primary" {
  name     = "v4-fsn1-primary"
  location = "fsn1"
  type     = "ipv4"

  auto_delete       = false
  delete_protection = true
}

resource "hcloud_primary_ip" "v6-fsn1-primary" {
  name     = "v6-fsn1-primary"
  location = "fsn1"
  type     = "ipv6"

  auto_delete       = false
  delete_protection = true
}

locals {
  network = {
    weird-row-v4-server = hcloud_primary_ip.v4-nbg1-primary.ip_address
    weird-row-v6_subnet = hcloud_primary_ip.v6-nbg1-primary.ip_network
    weird-row-v6-server = cidrhost(hcloud_primary_ip.v6-nbg1-primary.ip_network, 1)
    weird-row-v6-agnos  = cidrhost(hcloud_primary_ip.v6-nbg1-primary.ip_network, 2)

    rowrack-v4-server = hcloud_primary_ip.v4-fsn1-primary.ip_address
    rowrack-v6_subnet = hcloud_primary_ip.v6-fsn1-primary.ip_network
    rowrack-v6-server = cidrhost(hcloud_primary_ip.v6-fsn1-primary.ip_network, 1)
    rowrack-v6-agnos  = cidrhost(hcloud_primary_ip.v6-fsn1-primary.ip_network, 2)

    grebedoc-v4 = "185.187.152.7"
    grebedoc-v6 = "2a05:b0c4:1::3"
  }
}

output "network" {
  value = local.network
}

# Save network IPs for Nix config
resource "local_file" "network" {
  content  = jsonencode(local.network)
  filename = "network.json"
}
