{
  config,
  globals,
  ...
}:

{
  config = {
    local.ports.warrior = 3015;

    virtualisation.oci-containers.containers.archive-warrior = {
      image = "atdr.meo.ws/archiveteam/warrior-dockerfile";
      ports = [ "127.0.0.1:${config.local.ports.warrior.string}:8001" ];
      pull = "newer";

      environment = {
        DOWNLOADER = "wiro";
        SELECTED_PROJECT = "urls";
        CONCURRENT_ITEMS = "6";
      };
    };

    services.caddy = {
      virtualHosts."http://${globals.domains.warrior}".extraConfig = ''
        bind tailscale/warrior
        reverse_proxy http://localhost:${config.local.ports.warrior.string}
      '';
    };
  };
}
