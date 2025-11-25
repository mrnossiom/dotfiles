{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.services.logiops;

  libconfig-format = pkgs.formats.libconfig { };
  rendered-config = libconfig-format.generate "logid.cfg" cfg.settings;
in
{
  options.services.logiops = {
    enable = lib.mkEnableOption "Logiops HID++ configuration";

    package = lib.mkPackageOption pkgs "logiops_0_2_3" { };

    settings = lib.mkOption {
      type = libconfig-format.type;
      default = { };
      example = {
        devices = [{
          name = "Wireless Mouse MX Master 3";

          smartshift = {
            on = true;
            threshold = 20;
          };

          hiresscroll = {
            hires = true;
            invert = false;
            target = false;
          };

          dpi = 1500;

          buttons = [
            {
              cid = "0x53";
              action = {
                type = "Keypress";
                keys = [ "KEY_FORWARD" ];
              };
            }
            {
              cid = "0x56";
              action = {
                type = "Keypress";
                keys = [ "KEY_BACK" ];
              };
            }
          ];
        }];
      };
      description = lib.mdDoc ''
        Logid configuration. Refer to
        [the `logiops` wiki](https://github.com/PixlOne/logiops/wiki/Configuration)
        for details on supported values.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.udev.packages = [ pkgs.logitech-udev-rules ];
    environment.etc."logid.cfg".source = rendered-config;

    systemd.packages = [ cfg.package ];
    systemd.services.logid = {
      wantedBy = [ "multi-user.target" ];
      restartTriggers = [ rendered-config ];
    };
  };
}
