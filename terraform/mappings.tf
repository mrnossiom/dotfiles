## Servers

import {
  to = hcloud_server.weird-row-server
  id = "62287388"
}

## Networks

import {
  to = hcloud_primary_ip.primary-v4
  id = "85834839"
}
import {
  to = hcloud_primary_ip.primary-v6
  id = "85776061"
}

## DNS

import {
  to = hcloud_zone.wiro_world
  id = "50469"
}
import {
  to = hcloud_zone_rrset.wiro_world-weirdrow_portal-a
  id = "wiro.world/weird-row.portal/A"
}
import {
  to = hcloud_zone_rrset.wiro_world-weirdrow_portal-aaaa
  id = "wiro.world/weird-row.portal/AAAA"
}
import {
  to = hcloud_zone_rrset.wiro_world-tl-a
  id = "wiro.world/@/A"
}
import {
  to = hcloud_zone_rrset.wiro_world-tl-aaaa
  id = "wiro.world/@/AAAA"
}
import {
  to = hcloud_zone_rrset.wiro_world-knot-cname
  id = "wiro.world/knot/CNAME"
}
import {
  to = hcloud_zone_rrset.wiro_world-headscale-cname
  id = "wiro.world/headscale/CNAME"
}
import {
  to = hcloud_zone_rrset.wiro_world-auth-cname
  id = "wiro.world/auth/CNAME"
}
import {
  to = hcloud_zone_rrset.wiro_world-matrix-cname
  id = "wiro.world/matrix/CNAME"
}
import {
  to = hcloud_zone_rrset.wiro_world-news-cname
  id = "wiro.world/news/CNAME"
}
import {
  to = hcloud_zone_rrset.wiro_world-spindle-cname
  id = "wiro.world/spindle/CNAME"
}
import {
  to = hcloud_zone_rrset.wiro_world-stats-cname
  id = "wiro.world/stats/CNAME"
}
import {
  to = hcloud_zone_rrset.wiro_world-status-cname
  id = "wiro.world/status/CNAME"
}
import {
  to = hcloud_zone_rrset.wiro_world-vault-cname
  id = "wiro.world/vault/CNAME"
}
import {
  to = hcloud_zone_rrset.wiro_world-pds-cname
  id = "wiro.world/pds/CNAME"
}
import {
  to = hcloud_zone_rrset.wiro_world-wildcard_pds-cname
  id = "wiro.world/*.pds/CNAME"
}
import {
  to = hcloud_zone_rrset.wiro_world-kalei-cname
  id = "wiro.world/kalei/CNAME"
}
import {
  to = hcloud_zone_rrset.wiro_world-agnos_weirdrow_portal-aaaa
  id = "wiro.world/agnos.weird-row.portal/AAAA"
}
import {
  to = hcloud_zone_rrset.wiro_world-acme_challenge-ns
  id = "wiro.world/_acme-challenge/NS"
}
import {
  to = hcloud_zone_rrset.wiro_world-acme_challenge_net-ns
  id = "wiro.world/_acme-challenge.net/NS"
}
import {
  to = hcloud_zone_rrset.wiro_world-acme_challenge_pds-ns
  id = "wiro.world/_acme-challenge.pds/NS"
}
import {
  to = hcloud_zone_rrset.wiro_world-tl-mx
  id = "wiro.world/@/MX"
}
import {
  to = hcloud_zone_rrset.wiro_world-tl-txt
  id = "wiro.world/@/TXT"
}
import {
  to = hcloud_zone_rrset.wiro_world-dmarc-txt
  id = "wiro.world/_dmarc/TXT"
}
import {
  to = hcloud_zone_rrset.wiro_world-key1_domainkey-cname
  id = "wiro.world/key1._domainkey/CNAME"
}
import {
  to = hcloud_zone_rrset.wiro_world-key2_domainkey-cname
  id = "wiro.world/key2._domainkey/CNAME"
}
import {
  to = hcloud_zone_rrset.wiro_world-key3_domainkey-cname
  id = "wiro.world/key3._domainkey/CNAME"
}
import {
  to = hcloud_zone_rrset.wiro_world-autoconfig-cname
  id = "wiro.world/autoconfig/CNAME"
}
import {
  to = hcloud_zone_rrset.wiro_world-imaps_tcp-srv
  id = "wiro.world/_imaps._tcp/SRV"
}
import {
  to = hcloud_zone_rrset.wiro_world-submissions_tcp-srv
  id = "wiro.world/_submissions._tcp/SRV"
}
import {
  to = hcloud_zone_rrset.wiro_world-send_services-mx
  id = "wiro.world/send.services/MX"
}
import {
  to = hcloud_zone_rrset.wiro_world-send_services-txt
  id = "wiro.world/send.services/TXT"
}
import {
  to = hcloud_zone_rrset.wiro_world-resend_domainkey_services-txt
  id = "wiro.world/resend._domainkey.services/TXT"
}
import {
  to = hcloud_zone_rrset.wiro_world-atproto-txt
  id = "wiro.world/_atproto/TXT"
}

## Reverse DNS

import {
  to = hcloud_rdns.primary-v4
  id = "p-85834839-91.99.55.74"
}
import {
  to = hcloud_rdns.primary-v6
  id = "p-85776061-2a01:4f8:c2c:76d2::1"
}
