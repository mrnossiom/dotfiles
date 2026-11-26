{
  flake.modules.nixos.weird_row-ogama =
    { config, lib, ... }:
    let
      proxiedServices = [
        "app.lsi.ogama.me"
        "immich.ogama.me"
        "jellyfin.ogama.me"
        "lsi.ogama.me"
        "rustical.ogama.me"
        "wakapi.ogama.me"

        "lasceneinterieure.com"
      ];

      proxiedVirtualHosts = lib.genAttrs' proxiedServices (
        host:
        lib.nameValuePair host {
          extraConfig = ''
            reverse_proxy {
              dynamic a ipv6.ogama.me 443 {
                versions ipv6
              }

              transport http {
                tls
                tls_server_name ${host}
              }

              header_up Host {hostport}
            }
          '';
        }
      );
    in
    {
      services.caddy.virtualHosts = proxiedVirtualHosts;
    };
}
