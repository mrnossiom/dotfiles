{ self, system, ... }@pkgs:

let
  inherit (self.inputs) agenix git-leave mind radicle;
in
{
  findUnicode = pkgs.callPackage ./findUnicode.nix { };
  greenlight = pkgs.callPackage ./greenlight.nix { };
  overlayed = pkgs.callPackage ./overlayed.nix { };
  git-along = pkgs.callPackage ./git-along.nix { };
  rust-sloth = pkgs.callPackage ./rust-sloth.nix { };
  rusty-rain = pkgs.callPackage ./rusty-rain { };
  thorium = pkgs.callPackage ./thorium.nix { };

  # Import packages defined in foreign repositories
  inherit (agenix.packages.${system}) agenix;
  inherit (git-leave.packages.${system}) git-leave;
  inherit (mind.packages.${system}) mind;
  inherit (radicle.packages.${system}) radicle-cli radicle-remote-helper radicle-httpd radicle-node;
}
