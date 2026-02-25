{
  lib,
  llib,
  ...
}:

{
  domains = rec {
    # wiro.world
    wiro-world = "wiro.world";
    wiro-world-net = "net.${wiro-world}";

    # wiro.world public
    authelia = "auth.${wiro-world}";
    goatcounter = "stats.${wiro-world}";
    headscale = "headscale.${wiro-world}";
    matrix = "matrix.${wiro-world}";
    miniflux = "news.${wiro-world}";
    pds = "pds.${wiro-world}";
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
    thelounge = "irc-lounge.${wiro-world-net}";
    warrior = "warrior.${wiro-world-net}";

    # hypixel-bank-tracker.xyz
    hypixel-bank-tracker = "hypixel-bank-tracker.xyz";
    hbt-main = hypixel-bank-tracker;
    hbt-banana = "banana.${hypixel-bank-tracker}";
  };

  network =
    let
      pipeNoMask = [
        llib.net.decompose
        (addr: addr.addressNoMask)
      ];
    in
    rec {
      primary4 = llib.net.decompose "91.99.55.74";
      primary6-subnet = llib.net.decompose "2a01:4f8:c2c:76d2::/64";

      weird-row-server = lib.pipe primary4.address pipeNoMask;
      weird-row-server6 = lib.pipe (llib.net.assignAddress primary6-subnet.address 1) pipeNoMask;
      weird-row-server6-agnos = lib.pipe (llib.net.assignAddress primary6-subnet.address 2) pipeNoMask;
    };
}
