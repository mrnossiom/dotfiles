{ lib
, config
, ...
}:

let
  cfg = config.local.fragment.gaming;
in
{
  options.local.fragment.gaming.enable = lib.mkEnableOption ''
    Gaming related
  '';

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;

      # Open ports in the firewall for Steam Remote Play and Source Dedicated Server
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
  };
}
