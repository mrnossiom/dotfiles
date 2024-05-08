{ self, system, ... }@pkgs:

let
  inherit (self.inputs) agenix git-leave mind radicle wakatime-lsp;
in
{
  # Commented packages are broken

  arduino-udev-rules = pkgs.callPackage ./arduino-udev-rules.nix { };
  # cspell-lsp = pkgs.callPackage ./cspell-lsp { };
  findUnicode = pkgs.callPackage ./findUnicode.nix { };
  git-along = pkgs.callPackage ./git-along.nix { };
  # greenlight = pkgs.callPackage ./greenlight.nix { };
  names = pkgs.callPackage ./names.nix { };
  # overlayed = pkgs.callPackage ./overlayed.nix { };
  probe-rs-udev-rules = pkgs.callPackage ./probe-rs-udev-rules.nix { };
  rust-sloth = pkgs.callPackage ./rust-sloth.nix { };
  rusty-rain = pkgs.callPackage ./rusty-rain { };
  # serenityos-emoji-font = pkgs.callPackage ./serenityos-emoji-font.nix { };
  srgn = pkgs.callPackage ./srgn.nix { };

  # Import packages defined in foreign repositories
  inherit (agenix.packages.${system}) agenix;
  inherit (git-leave.packages.${system}) git-leave;
  inherit (mind.packages.${system}) mind;
  inherit (radicle.packages.${system}) radicle-cli radicle-remote-helper radicle-httpd radicle-node;
  inherit (wakatime-lsp.packages.${system}) wakatime-lsp;
}
