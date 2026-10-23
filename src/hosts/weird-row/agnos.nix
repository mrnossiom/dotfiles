{ self, ... }:
{
  flake.modules.nixos.weird_row-agnos = { config, ... }: {
    config = {
      local.ports.agnos = {
        number = 53;
        public = true;
        tcp = false; # let agnos manage the firewall
      };

      # needed in caddy-tailscale
      users.groups.agnos.gid = 980;

      sops.secrets."agnos/account_key" = {
        owner = config.security.agnos.user;
      };

      security.agnos = {
        enable = true;
        temporarilyOpenFirewall = true;
        settings = {
          dns_listen_addr = "[${self.globals.network.weird-row-v6-agnos.addressNoMask}]:53";

          accounts = [
            {
              email = "admin@wiro.world";
              private_key_path = config.sops.secrets."agnos/account_key".path;
              certificates = [
                {
                  domains = [
                    "wiro.world"
                    "*.wiro.world"
                  ];
                  fullchain_output_file = "wiro.world_fullchain.pem";
                  key_output_file = "wiro.world_privkey.pem";
                }
                {
                  domains = [
                    "pds.wiro.world"
                    "*.pds.wiro.world"
                  ];
                  fullchain_output_file = "pds.wiro.world_fullchain.pem";
                  key_output_file = "pds.wiro.world_privkey.pem";
                }
                {
                  domains = [
                    "net.wiro.world"
                    "*.net.wiro.world"
                  ];
                  fullchain_output_file = "net.wiro.world_fullchain.pem";
                  key_output_file = "net.wiro.world_privkey.pem";
                }
              ];
            }
          ];
        };
      };
    };
  };
}
