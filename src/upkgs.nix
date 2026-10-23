{ inputs, lib, ... }:
let
  # List of all unfree packages authorized
  unfreePredicate =
    package:
    builtins.elem (lib.getName package) [
      # NixOS
      "hplip"
      "steam"
      "steam-original"
      "steam-run"
      "steam-unwrapped"
      "xone-dongle-firmware"

      # Home Manager
      "aseprite"
      "ida-free"
      "jetbrains-toolbox"
      "vscode-extension-ms-vsliveshare-vsliveshare"
    ];

in
{
  perSystem = { pkgs, system, ... }: {
    _module.args = {
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfreePredicate = unfreePredicate;
      };
      upkgs = import inputs.unixpkgs {
        inherit system;
        inherit (pkgs) config;
      };
    };
  };
}
