# We need a second caddy instance to support the tailscale plugin,
# else we have a dependency cycle: `authelia → caddy → tailscale → authelia`
#
# A light container is the simplest way to configure it.
{ self, ... }:
{
  flake.modules.nixos.weird_row-caddy-tailscale =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.local.tailscale.net;
      enabledBinds = lib.filterAttrs (name: box: box.enable) cfg.binds;
      checkedBinds = lib.filterAttrs (name: box: box.domain != null) cfg.binds;
    in
    {
      options.local.tailscale.net = {
        baseDomain = lib.mkOption {
          type = lib.types.str;
          example = "net.example.com";
        };

        cert.keyFile = lib.mkOption {
          type = lib.types.path;
          example = "/var/lib/agnos/net.example.com_privkey.pem";
        };

        cert.fullchainFile = lib.mkOption {
          type = lib.types.path;
          example = "/var/lib/agnos/net.example.com_fullchain.pem";
        };

        binds = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule (
              { name, config, ... }: {
                options = {
                  enable = lib.mkEnableOption "this Hetzner Storage Box mount";

                  name = lib.mkOption {
                    type = lib.types.str;
                    readOnly = true;
                    example = "foo";
                  };

                  domain = lib.mkOption {
                    type = lib.types.nullOr lib.types.str;
                    example = "foo.net.example.com";
                    description = "Assert the resulting domain";
                  };

                  port = lib.mkOption {
                    type = lib.types.port;
                  };
                };
                config = {
                  inherit name;
                };
              }
            )
          );
          default = { };
          example = {
            service1.port = 3001;
            service2 = {
              port = 3002;
              domain = "service2.net.example.com";
            };
          };
        };
      };

      config = {
        containers.caddy-tailscale = {
          autoStart = true;
          privateNetwork = false;

          bindMounts = {
            "/var/lib/agnos/".isReadOnly = true;
            "/run/agenix/".isReadOnly = true;
          };

          config = {
            system.stateVersion = config.system.stateVersion;

            # used to link the "host-agnos" group in the container to the host
            # "agnos" group needed to read the certs
            users.groups.host-agnos.gid = 980;
            users.users.caddy.extraGroups = [ "host-agnos" ];

            services.caddy = {
              enable = true;
              package = pkgs.caddy.withPlugins {
                plugins = [
                  "github.com/tailscale/caddy-tailscale@v0.0.0-20251016213337-01d084e119cb"
                ];
                hash = "sha256-tUVp32+dj9h0FBFcQ7m0OVBe0bxaR6uFRACrFPOUs3c=";
              };

              environmentFile = config.age.secrets.caddy-env.path;

              globalConfig = ''
                auto_https off

                tailscale {
                  control_url https://headscale.wiro.world
                  ephemeral
                }
              '';

              virtualHosts = lib.mapAttrs' (
                name:
                { port, ... }:
                let
                  extraConfig = ''
                    bind tailscale/${name}
                    tls ${cfg.cert.fullchainFile} ${cfg.cert.keyFile}
                    reverse_proxy http://localhost:${toString port}
                  '';
                in
                lib.nameValuePair "${name}.${cfg.baseDomain}" { inherit extraConfig; }
              ) enabledBinds;
            };
          };
        };

        assertions = lib.mapAttrsToList (name: { domain, ... }: {
          assertion = "${name}.${cfg.baseDomain}" == domain;
          message = "expected domain did not match actual domain: got '${name}.${cfg.baseDomain}', expected '${domain}'";
        }) checkedBinds;

        local.tailscale.net = {
          baseDomain = self.globals.domains.wiro-world-net;
          cert.keyFile = "/var/lib/agnos/net.wiro.world_privkey.pem";
          cert.fullchainFile = "/var/lib/agnos/net.wiro.world_fullchain.pem";
        };
      };
    };
}
