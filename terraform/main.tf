terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

variable "hcloud_token" {
  sensitive = true
}

resource "hcloud_primary_ip" "primary-v4" {
  name     = "primary-v4"
  location = "nbg1"
  type     = "ipv4"

  assignee_type     = "server"
  auto_delete       = false
  delete_protection = true
}

resource "hcloud_primary_ip" "primary-v6" {
  name     = "primary-v6"
  location = "nbg1"
  type     = "ipv6"

  assignee_type     = "server"
  auto_delete       = false
  delete_protection = true
}

locals {
  network = {
    weird-row-server-v4       = hcloud_primary_ip.primary-v4.ip_address
    weird-row-server-v6       = cidrhost(hcloud_primary_ip.primary-v6.ip_network, 1)
    weird-row-server-v6-agnos = cidrhost(hcloud_primary_ip.primary-v6.ip_network, 2)

    grebedoc-v4 = "185.187.152.7"
    grebedoc-v6 = "2a05:b0c4:1::3"
  }
}

output "network" {
  value = local.network
}
