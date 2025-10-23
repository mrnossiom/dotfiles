{ config
, lib
, pkgs
, ...
}:
with lib; let
  cfg = config.services.mindustry-server;
in
{
  options = {
    services.mindustry-server = {
      enable = mkEnableOption "Mindustry server";

      package = mkPackageOption pkgs "mindustry-server" { };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open ports in the firewall for the mindustry server";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.mindustry = {
      description = "Mindustry server";

      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/mindustry-server host";
        DynamicUser = true;
      };

      wantedBy = [ "multi-user.target" ];
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ 6567 ];
      allowedUDPPorts = [ 6567 ];
    };
  };
}

