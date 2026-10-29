{
  self,
  inputs,
  moduleWithSystem,
  ...
}:
let
  did-wiro-world = "did:plc:xhgrjm4mcx3p5h3y6eino6ti";
in
{
  flake.modules.nixos.weird_row-tangled = moduleWithSystem (
    { inputs', ... }:
    { config, lib, ... }:
    {
      imports = [
        inputs.tangled.nixosModules.knot
        inputs.tangled.nixosModules.knot-rs
        inputs.tangled.nixosModules.spindle
      ];

      config = {
        local.ports.tangled-knot = 3004;

        age.secrets.tangled-knot2-env.file = secrets/tangled-knot2-env.age;

        age.secrets.storage-box-creds-tangled.file = secrets/storage-box-creds-tangled.age;

        services.hetzner.storageBoxes.tangled = {
          enable = true;
          username = "u701292-sub6";
          credentialsFile = config.age.secrets.storage-box-creds-tangled.path;
          owner = "knot";
        };

        services.tangled.knot-rs = {
          enable = true;
          environmentFile = config.age.secrets.tangled-knot2-env.path;

          openFirewall = true;

          settings = {
            motd = "Welcome to @wiro.world's knot!\n";

            contact.email = "milo@wiro.world";

            server = {
              hostname = "knot.wiro.world";
              admins = [ did-wiro-world ];

              listen_addr = "127.0.0.1:${config.local.ports.tangled-knot.string}";
              ssh_listen_addr = "[::]:2222";
            };

            acl.admission = "closed";

            # repo.scan_path = "";
            # lfs.store_path = "";
            # secrets.sealed_key_file = "";
            git.object_format = "sha256";

            atproto.plc_directory = "https://plc.directory";
            xrpc.trusted_proxy_header = "x-forwarded-for";
          };
        };

        services.caddy.virtualHosts.${self.globals.domains.tangled-knot}.extraConfig = ''
          reverse_proxy http://localhost:${config.local.ports.tangled-knot.string}
        '';
      };
    }
  );
}
