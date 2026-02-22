{
  config,
  globals,
  ...
}:

{
  config = {
    local.ports.goatcounter = 3010;

    services.goatcounter = {
      enable = true;

      port = config.local.ports.goatcounter.number;
      proxy = true;
      # TODO: use caddy log instead js script to get visit information
      extraArgs = [ "-automigrate" ];
    };

    services.caddy.virtualHosts.${globals.domains.goatcounter}.extraConfig = ''
      reverse_proxy http://localhost:${toString config.services.goatcounter.port}
    '';
  };
}
