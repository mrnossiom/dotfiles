{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.programs.screen;
in

{
  options = {
    programs.screen = {
      enable = lib.mkEnableOption "screen, a basic terminal multiplexer";

      package = lib.mkPackageOption pkgs "screen" { };

      screenrc = lib.mkOption {
        type = lib.types.lines;
        default = "";
        example = ''
          defscrollback 10000
          startup_message off
        '';
        description = "The contents of {file}`/etc/screenrc` file";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."screen/screenrc".text = cfg.screenrc;

    home.sessionVariables = {
      SCREENRC = "${config.xdg.configHome}/screen/screenrc";
      SCREENDIR = "${config.xdg.configHome}/screen";
    };

    home.packages = [ cfg.package ];
  };
}
