{
  self,
  config,
  globals,
  ...
}:

{
  imports = [ self.nixosModules.git-pages ];

  config = {
    local.ports.git-pages = 3017;

    services.git-pages = {
      enable = true;
      settings = {
        log-format = "text";

        server = {
          pages = "tcp/localhost:${config.local.ports.git-pages.string}";
          caddy = "-";
          metrics = "-";
        };

        # TODO: fallback to 404 page
      };
    };

    services.caddy.virtualHosts.${globals.domains.pages} = {
      serverAliases = [ "test.wiro.world" ];
      extraConfig = ''
        # TODO: enforce some kind of authentication for publishing websites
        # @write_ops { not method GET HEAD }
        # basicauth @write_ops { }

        reverse_proxy http://localhost:${config.local.ports.git-pages.string}
      '';
    };
  };
}
