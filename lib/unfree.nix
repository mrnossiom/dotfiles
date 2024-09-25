{ lib }:

# List of all unfree packages authorized
package: builtins.elem (lib.getName package) [
  # NixOS
  "hplip"
  "steam"
  "steam-original"
  "steam-run"

  # Home Manager
  "cloudflare-warp"
  "geogebra"
  "spotify"
  "unityhub"
  ## JetBrains
  "datagrip"
  "rider"
]
