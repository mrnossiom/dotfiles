{ inputs, lib, ... }:

{
  flake.globals = {
    domains = rec {
      # wiro.world
      wiro-world = "wiro.world";
      wiro-world-net = "net.${wiro-world}";

      # wiro.world public
      authelia = "auth.${wiro-world}";
      cdav = "cdav.${wiro-world}";
      goatcounter = "stats.${wiro-world}";
      headscale = "headscale.${wiro-world}";
      hedgedoc = "hedgedoc.${wiro-world}";
      jellyfin = "jellyfin.${wiro-world}";
      miniflux = "news.${wiro-world}";
      pds = "pds.${wiro-world}";
      static = "static.${wiro-world}";
      status = "status.${wiro-world}";
      tangled-knot = "knot.${wiro-world}";
      tangled-spindle = "spindle.${wiro-world}";
      vaultwarden = "vault.${wiro-world}";
      website = wiro-world;

      # wiro.world projects
      kaleic = "kaleic.${wiro-world}";
      usp = "usp.${wiro-world}";

      # wiro.world private net
      grafana = "console.${wiro-world-net}";
      lldap = "ldap.${wiro-world-net}";
      slskd = "slskd.${wiro-world-net}";

      # hypixel-bank-tracker.xyz
      hypixel-bank-tracker = "hypixel-bank-tracker.xyz";
      hbt-main = hypixel-bank-tracker;
      hbt-banana = "banana.${hypixel-bank-tracker}";
    };

    network =
      let
        libnet = inputs.net.lib;
        networks = lib.fromJSON (lib.fileContents ../terraform/network.json);
      in
      lib.mapAttrs (name: ip: libnet.decompose ip) networks;

    # User keys (~/.ssh/id_{ed25519,ecdsa}.pub)
    pubkeys = rec {
      milo-ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJdt7atyPTOfaBIsgDYYb0DG1yid2u78abaCDji6Uxgi";
      wirody = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMdW6ijH9oTsrswUJmQBF2LQkhjrMFkJ1LktnirPuL2S";
      groups.users = [
        milo-ed25519
        wirody
      ];

      epita = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPxVZAdPQ5qEsA/D2eTHsbetI+l5TBhIkT5DFHdn+f/6";
    };
  };
}
