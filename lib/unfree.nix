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
  "gurobi"
  "gurobipy"
  "ida-free"
  "jetbrains-toolbox"
  "spotify"
  "vscode-extension-ms-vsliveshare-vsliveshare"
]
