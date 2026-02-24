{
  config,
  globals,
  ...
}:

{
  config = {
    local.ports.agnos = {
      number = 53;
      public = true;
      tcp = false; # let agnos manage the firewall
    };

    age.secrets.agnos-account-key = {
      file = secrets/agnos-account-key.age;
      owner = config.security.agnos.user;
    };
    security.agnos = {
      enable = true;
      temporarilyOpenFirewall = true;
      settings = {
        dns_listen_addr = "[${globals.hosts.weird-row-server.ip6-agnos}]:53";

        accounts = [
          {
            email = "admin@wiro.world";
            private_key_path = config.age.secrets.agnos-account-key.path;
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
}
