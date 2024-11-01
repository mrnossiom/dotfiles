{ config
, lib

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
    hardware.uinput.enable = true;

    services.kanata = {
      enable = true;

      keyboards.neo-integrated = {
        devices = [
          # TODO: should be `by-id`, : in name cause issues
          # "/dev/input/by-path/pci-0000:00:15.0-platform-i2c_designware.0-event-kbd"
        ];

        # Ergo-L Arsenik layout
        # See <https://ergol.org/claviers/arsenik> for mentionned reference files
        config = builtins.readFile ./arsenik.kbd.lisp;
      };
    };
  };
}
