{
  flake.modules.nixos.weird_row-ogama =
    { config, lib, ... }:
    let
      proxiedServices = [
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
