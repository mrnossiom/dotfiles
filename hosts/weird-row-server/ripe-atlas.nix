{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = {
    local.ports.ripe-atlas-http = 3016;
    local.ports.ripe-atlas-telnetd = 3017;

    virtualisation.oci-containers.containers."ripe-atlas" = {
      image = "docker.io/jamesits/ripe-atlas:latest";

      capabilities = {
        "NET_RAW" = true;
        "KILL" = true;
        "SETUID" = true;
        "SETGID" = true;
        "FOWNER" = true;
        "CHOWN" = true;
        "DAC_OVERRIDE" = true;
      };

      environment = {
        RXTXRPT = "yes";
        HTTP_POST_PORT = config.local.ports.ripe-atlas-http.string;
        TELNETD_PORT = config.local.ports.ripe-atlas-telnetd.string;
      };

      volumes = [
        "/etc/ripe-atlas:/etc/ripe-atlas:Z"
        "/run/ripe-atlas:/run/ripe-atlas:Z"
        "/var/spool/ripe-atlas:/var/spool/ripe-atlas:Z"
      ];

      extraOptions = [
        "--memory=256m"
        "--network=host"
      ];
    };

    systemd.services."podman-ripe-atlas" =
      let
        mkdir = lib.getExe' pkgs.coreutils "mkdir";
      in

      {
        preStart = ''
          ${mkdir} -p /run/ripe-atlas
          ${mkdir} -p /etc/ripe-atlas
          ${mkdir} -p /var/spool/ripe-atlas
        '';
        serviceConfig = {
          Restart = "always";
          RestartSec = "10s";
        };
      };
  };
}
