{
  flake.modules.nixos.weird_row-ogama =
    { config, lib, ... }:
    let
      proxiedServices = [
        "app.lsi"
        "immich"
        "jellyfin"
        "lsi"
        "rustical"
        "wakapi"
      ];

      proxiedVirtualHosts = lib.genAttrs' proxiedServices (
        service:
        let
          host = "${service}.ogama.me";
          extraConfig = ''
            reverse_proxy {
              dynamic a ipv6.ogama.me 443 {
                versions ipv6
              }

              transport http {
                tls
                tls_server_name ${service}.ogama.me
              }

              header_up Host {hostport}
            }
          '';
        in
        lib.nameValuePair host { inherit extraConfig; }
      );
    in
    {
      services.caddy.virtualHosts = proxiedVirtualHosts;
    };
}
