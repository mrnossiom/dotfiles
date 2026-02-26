{
  config,
  lib,
  ...
}:

let
  cfg = config.local.fragment.heriot-watt;

  hw-username = "mm4172";
in
{
  options.local.fragment.heriot-watt.enable = lib.mkEnableOption ''
    Heriot-Watt related
  '';

  config = lib.mkIf cfg.enable {
    programs.ssh.matchBlocks."robotarium" = {
      # hostname = "robotarium.hw.ac.uk";
      # do not rely on local network DNS resolver
      hostname = "137.195.243.70";
      user = hw-username;
    };
  };
}
