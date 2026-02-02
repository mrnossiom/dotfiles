{
  globals,
  ...
}:

{
  config = {
    local.ports.tailscale-exporter = 9005;

    # age.secrets.tailscale-authkey.file = secrets/tailscale-authkey.age;
    services.tailscale = {
      enable = true;
      extraSetFlags = [ "--advertise-exit-node" ];
      # authKeyFile = config.age.secrets.tailscale-authkey.path;
      authKeyParameters = {
        baseURL = "https://${globals.domains.headscale}";
        ephemeral = true;
        preauthorized = true;
      };
    };
  };
}
