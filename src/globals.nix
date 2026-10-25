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
      public = "public.${wiro-world}";
      status = "status.${wiro-world}";
      tangled-knot = "knot.${wiro-world}";
      tangled-spindle = "spindle.${wiro-world}";
      vaultwarden = "vault.${wiro-world}";
      website = wiro-world;

      # wiro.world projects
      kaleic = "kaleic.${wiro-world}";

      # wiro.world private net
      grafana = "console.${wiro-world-net}";
      lldap = "ldap.${wiro-world-net}";
      warrior = "warrior.${wiro-world-net}";

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
  };
}
