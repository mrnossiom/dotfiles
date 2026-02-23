resource "hcloud_zone" "wiro_world" {
  name = "wiro.world"
  mode = "primary"

  delete_protection = true
}

## Portals

resource "hcloud_zone_rrset" "wiro_world-weirdrow_portal-a" {
  zone = hcloud_zone.wiro_world.name
  name = "weird-row.portal"
  type = "A"
  records = [
    { value = local.network.weird-row-server },
  ]
  labels = {
    portal = "",
  }
}
resource "hcloud_zone_rrset" "wiro_world-weirdrow_portal-aaaa" {
  zone = hcloud_zone.wiro_world.name
  name = "weird-row.portal"
  type = "AAAA"
  records = [
    { value = local.network.weird-row-server6 },
  ]
  labels = {
    portal = "",
  }
}

## Hosted services

resource "hcloud_zone_rrset" "wiro_world-tl-a" {
  zone = hcloud_zone.wiro_world.name
  name = "@"
  type = "A"
  records = [
    { value = local.network.weird-row-server },
  ]
}
resource "hcloud_zone_rrset" "wiro_world-tl-aaaa" {
  zone = hcloud_zone.wiro_world.name
  name = "@"
  type = "AAAA"
  records = [
    { value = local.network.weird-row-server6 },
  ]
}

resource "hcloud_zone_rrset" "wiro_world-knot-cname" {
  zone = hcloud_zone.wiro_world.name
  name = "knot"
  type = "CNAME"
  records = [
    { value = "weird-row.portal" },
  ]
}
resource "hcloud_zone_rrset" "wiro_world-headscale-cname" {
  zone = hcloud_zone.wiro_world.name
  name = "headscale"
  type = "CNAME"
  records = [
    { value = "weird-row.portal" },
  ]
}
resource "hcloud_zone_rrset" "wiro_world-auth-cname" {
  zone = hcloud_zone.wiro_world.name
  name = "auth"
  type = "CNAME"
  records = [
    { value = "weird-row.portal" },
  ]
}
resource "hcloud_zone_rrset" "wiro_world-matrix-cname" {
  zone = hcloud_zone.wiro_world.name
  name = "matrix"
  type = "CNAME"
  records = [
    { value = "weird-row.portal" },
  ]
}
resource "hcloud_zone_rrset" "wiro_world-news-cname" {
  zone = hcloud_zone.wiro_world.name
  name = "news"
  type = "CNAME"
  records = [
    { value = "weird-row.portal" },
  ]
}
resource "hcloud_zone_rrset" "wiro_world-spindle-cname" {
  zone = hcloud_zone.wiro_world.name
  name = "spindle"
  type = "CNAME"
  records = [
    { value = "weird-row.portal" },
  ]
}
resource "hcloud_zone_rrset" "wiro_world-stats-cname" {
  zone = hcloud_zone.wiro_world.name
  name = "stats"
  type = "CNAME"
  records = [
    { value = "weird-row.portal" },
  ]
}
resource "hcloud_zone_rrset" "wiro_world-status-cname" {
  zone = hcloud_zone.wiro_world.name
  name = "status"
  type = "CNAME"
  records = [
    { value = "weird-row.portal" },
  ]
}
resource "hcloud_zone_rrset" "wiro_world-vault-cname" {
  zone = hcloud_zone.wiro_world.name
  name = "vault"
  type = "CNAME"
  records = [
    { value = "weird-row.portal" },
  ]
}

resource "hcloud_zone_rrset" "wiro_world-pds-cname" {
  zone = hcloud_zone.wiro_world.name
  name = "pds"
  type = "CNAME"
  records = [
    { value = "weird-row.portal" },
  ]
  labels = {
    atproto = "",
  }
}
resource "hcloud_zone_rrset" "wiro_world-wildcard_pds-cname" {
  zone = hcloud_zone.wiro_world.name
  name = "*.pds"
  type = "CNAME"
  records = [
    { value = "weird-row.portal" },
  ]
  labels = {
    atproto = "",
  }
}

## External services

resource "hcloud_zone_rrset" "wiro_world-kalei-cname" {
  zone = hcloud_zone.wiro_world.name
  name = "kalei"
  type = "CNAME"
  records = [
    { value = "github.io." },
  ]
}

## Agnos

resource "hcloud_zone_rrset" "wiro_world-agnos_weirdrow_portal-aaaa" {
  zone = hcloud_zone.wiro_world.name
  name = "agnos.weird-row.portal"
  type = "AAAA"
  records = [
    { value = local.network.weird-row-server6-agnos },
  ]
  labels = {
    agnos = "",
  }
}

resource "hcloud_zone_rrset" "wiro_world-acme_challenge-ns" {
  zone = hcloud_zone.wiro_world.name
  name = "_acme-challenge"
  type = "NS"
  records = [
    { value = "agnos.weird-row.portal" },
  ]
  labels = {
    agnos = "",
  }
}
resource "hcloud_zone_rrset" "wiro_world-acme_challenge_net-ns" {
  zone = hcloud_zone.wiro_world.name
  name = "_acme-challenge.net"
  type = "NS"
  records = [
    { value = "agnos.weird-row.portal" },
  ]
  labels = {
    agnos = "",
  }
}
resource "hcloud_zone_rrset" "wiro_world-acme_challenge_pds-ns" {
  zone = hcloud_zone.wiro_world.name
  name = "_acme-challenge.pds"
  type = "NS"
  records = [
    { value = "agnos.weird-row.portal" },
  ]
  labels = {
    agnos = "",
  }
}

## Mail

resource "hcloud_zone_rrset" "wiro_world-tl-mx" {
  zone = hcloud_zone.wiro_world.name
  name = "@"
  type = "MX"
  records = [
    { value = "10 aspmx1.migadu.com." },
    { value = "20 aspmx2.migadu.com." },
  ]
  labels = {
    mail = "",
  }
}
resource "hcloud_zone_rrset" "wiro_world-tl-txt" {
  zone = hcloud_zone.wiro_world.name
  name = "@"
  type = "TXT"
  records = [
    { value = provider::hcloud::txt_record("hosted-email-verify=uxyn9qye") },
    { value = provider::hcloud::txt_record("v=spf1 include:spf.migadu.com -all") },
  ]
  labels = {
    mail = "",
  }
}
resource "hcloud_zone_rrset" "wiro_world-dmarc-txt" {
  zone = hcloud_zone.wiro_world.name
  name = "_dmarc"
  type = "TXT"
  records = [
    { value = provider::hcloud::txt_record("v=DMARC1;p=quarantine;") },
  ]
  labels = {
    mail = "",
  }
}

resource "hcloud_zone_rrset" "wiro_world-key1_domainkey-cname" {
  zone = hcloud_zone.wiro_world.name
  name = "key1._domainkey"
  type = "CNAME"
  records = [
    { value = "key1.wiro.world._domainkey.migadu.com." },
  ]
  labels = {
    mail = "",
  }
}
resource "hcloud_zone_rrset" "wiro_world-key2_domainkey-cname" {
  zone = hcloud_zone.wiro_world.name
  name = "key2._domainkey"
  type = "CNAME"
  records = [
    { value = "key2.wiro.world._domainkey.migadu.com." },
  ]
  labels = {
    mail = "",
  }
}
resource "hcloud_zone_rrset" "wiro_world-key3_domainkey-cname" {
  zone = hcloud_zone.wiro_world.name
  name = "key3._domainkey"
  type = "CNAME"
  records = [
    { value = "key3.wiro.world._domainkey.migadu.com." },
  ]
  labels = {
    mail = "",
  }
}

resource "hcloud_zone_rrset" "wiro_world-autoconfig-cname" {
  zone = hcloud_zone.wiro_world.name
  name = "autoconfig"
  type = "CNAME"
  records = [
    { value = "autoconfig.migadu.com." },
  ]
  labels = {
    mail = "",
  }
}
resource "hcloud_zone_rrset" "wiro_world-imaps_tcp-srv" {
  zone = hcloud_zone.wiro_world.name
  name = "_imaps._tcp"
  type = "SRV"
  records = [
    { value = "0 1 993 imap.migadu.com" },
  ]
  labels = {
    mail = "",
  }
}
resource "hcloud_zone_rrset" "wiro_world-submissions_tcp-srv" {
  zone = hcloud_zone.wiro_world.name
  name = "_submissions._tcp"
  type = "SRV"
  records = [
    { value = "0 1 465 smtp.migadu.com" },
  ]
  labels = {
    mail = "",
  }
}

resource "hcloud_zone_rrset" "wiro_world-send_services-mx" {
  zone = hcloud_zone.wiro_world.name
  name = "send.services"
  type = "MX"
  records = [
    { value = "10 feedback-smtp.eu-west-1.amazonses.com." },
  ]
  labels = {
    mail = "",
  }
}
resource "hcloud_zone_rrset" "wiro_world-send_services-txt" {
  zone = hcloud_zone.wiro_world.name
  name = "send.services"
  type = "TXT"
  records = [
    { value = provider::hcloud::txt_record("v=spf1 include:amazonses.com ~all") },
  ]
  labels = {
    mail = "",
  }
}
resource "hcloud_zone_rrset" "wiro_world-resend_domainkey_services-txt" {
  zone = hcloud_zone.wiro_world.name
  name = "resend._domainkey.services"
  type = "TXT"
  records = [
    { value = provider::hcloud::txt_record("p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDRtv2LsjWWf6UjdtD9Ri8J2kmm+mWRqlnH+pY18UnbYZ/Ia8X3tLFFIda7IjQQ7iEDmkVETDPG6uxszUnMaZZZGQtN+XyY290FfoEPX1Cyi7AYHJKK40pgylynxA0KGjp5+vO/+9nxtReCYmLZIIhJ9uxHyQXCPxLfzl+Cq0uxMwIDAQAB") },
  ]
  labels = {
    mail = "",
  }
}

## Identification

resource "hcloud_zone_rrset" "wiro_world-atproto-txt" {
  zone = hcloud_zone.wiro_world.name
  name = "_atproto"
  type = "TXT"
  records = [
    { value = provider::hcloud::txt_record("did=did:plc:xhgrjm4mcx3p5h3y6eino6ti") },
  ]
  labels = {
    atproto = "",
  }
}

## Reverse DNS

resource "hcloud_rdns" "primary-v4" {
  primary_ip_id = hcloud_primary_ip.primary-v4.id
  ip_address    = hcloud_primary_ip.primary-v4.ip_address
  dns_ptr       = "weird-row.portal.wiro.world"
}
resource "hcloud_rdns" "primary-v6" {
  primary_ip_id = hcloud_primary_ip.primary-v6.id
  ip_address    = cidrhost(hcloud_primary_ip.primary-v6.ip_network, 1)
  dns_ptr       = "weird-row.portal.wiro.world"
}
