{ config
, lib
, upkgs

, ...
}:

let
  cfg = config.local.fragment.kanata;
in

{
  options.local.fragment.kanata.enable = lib.mkEnableOption ''
    Kanata and Ergo-L related
  '';

  config = lib.mkIf cfg.enable {
    services.kanata = {
      enable = true;
      package = upkgs.kanata;

      keyboards.neo-integrated = {
        devices = [
          # "/dev/input/by-path/pci-0000:00:15.0-platform-i2c_designware.0-event-kbd"
          "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
        ];

        extraDefCfg = "process-unmapped-keys yes";

        # Qwerty Arsenik layout
        # See <https://ergol.org/claviers/arsenik> for mentionned reference files
        config = builtins.readFile ./arsenik.kbd.lisp;
      };
    };
  };
}
