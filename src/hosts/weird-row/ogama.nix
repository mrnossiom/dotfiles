{
  flake.modules.nixos.weird_row-ogama =
    { config, lib, ... }:
    let
      proxiedServices = [
        "calino"
        "immich"
        "jellyfin"
        "qbittorrent"
        "rustical"
        "wakapi"
      ];

      proxiedVirtualHosts = lib.genAttrs' proxiedServices (
        service:
        let
          host = "https://${service}.ogama.me";
          extraConfig = ''
            reverse_proxy https://${service}.ipv6.ogama.me
          '';
        in
        lib.nameValuePair host { inherit extraConfig; }
      );
    in
    {
      services.caddy.virtualHosts = proxiedVirtualHosts;
    };
}
