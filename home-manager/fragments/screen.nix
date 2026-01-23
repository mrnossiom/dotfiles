{
  self,
  config,
  lib,
  ...
}:

let
  inherit (self) homeManagerModules;
  cfg = config.local.fragment.screen;
in
{
  imports = [ homeManagerModules.screen ];

  options.local.fragment.screen.enable = lib.mkEnableOption ''
    Screen related
  '';

  config = lib.mkIf cfg.enable {
    programs.screen = {
      enable = true;

      screenrc = ''
        startup_message off

        defscrollback 10000
      '';
    };
  };
}
