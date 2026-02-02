{
  domains = rec {
    wiro-world = "wiro.world";
    wiro-world-net = "net.${wiro-world}";
    hypixel-bank-tracker = "hypixel-bank-tracker.xyz";

    # wiro.world Public
    authelia = "auth.${wiro-world}";
    goatcounter = "stats.${wiro-world}";
    headscale = "headscale.${wiro-world}";
    matrix = "matrix.${wiro-world}";
    miniflux = "news.${wiro-world}";
    pds = "pds.${wiro-world}";
    tangled-knot = "knot.${wiro-world}";
    tangled-spindle = "spindle.${wiro-world}";
    vaultwarden = "vault.${wiro-world}";
    website = wiro-world;

    # wiro.world private net
    grafana = "console.${wiro-world-net}";
    lldap = "ldap.${wiro-world-net}";
    thelounge = "irc-lounge.${wiro-world-net}";
    warrior = "warrior.${wiro-world-net}";

    hbt-main = hypixel-bank-tracker;
    hbt-banana = "banana.${hypixel-bank-tracker}";
  };
}
