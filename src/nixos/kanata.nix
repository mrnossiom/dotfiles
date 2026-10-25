{
  # Kanata and Ergo-L related
  flake.modules.nixos.kanata = { ... }: {
    config = {
      services.kanata = {
        enable = true;

        keyboards.neo-integrated = {
          devices = [
            # archaic-wiro integrated keyboard
            "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
          ];

          extraDefCfg = "process-unmapped-keys yes";

          # Qwerty Arsenik layout
          # See <https://ergol.org/claviers/arsenik> for mentioned reference files
          config = builtins.readFile ./arsenik.kbd.lisp;
        };
      };
    };
  };
}
