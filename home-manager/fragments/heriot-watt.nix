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
      hostname = "robotarium.hw.ac.uk";
      user = hw-username;
    };
  };
}
