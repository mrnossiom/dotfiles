pkgs:

# List of all unfree packages authorized

let
  inherit (builtins) elem;
  inherit (pkgs.lib) getName;
in
package: elem (getName package) [
  # NixOS
  "steam"
  "steam-original"
  "steam-run"

  # Home Manager
  "authy"
  "discord"
  "spotify"
  "thorium-browser"
  "unrar"
  "geogebra"
]
