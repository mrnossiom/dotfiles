{ lib }:

# List of all unfree packages authorized
package: builtins.elem (lib.getName package) [
  # NixOS
  "hplip"
  "steam"
  "steam-original"
  "steam-run"
  "steam-unwrapped"

  # Home Manager
  "aseprite"
  "ida-free"
  "jetbrains-toolbox"
  "spotify"
  "unityhub"
]
