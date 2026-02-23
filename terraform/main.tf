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
    weird-row-server        = hcloud_primary_ip.primary-v4.ip_address
    weird-row-server6       = cidrhost(hcloud_primary_ip.primary-v6.ip_network, 1)
    weird-row-server6-agnos = cidrhost(hcloud_primary_ip.primary-v6.ip_network, 2)
  }
}

output "network" {
  value = local.network
}
