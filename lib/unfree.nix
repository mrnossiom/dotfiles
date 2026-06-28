{ lib }:

# List of all unfree packages authorized
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
]
