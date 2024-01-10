{ self, system, ... }@pkgs:

let
  inherit (self.inputs) agenix git-leave mind radicle;
in
{
  greenlight = pkgs.callPackage ./greenlight.nix { };
  overlayed = pkgs.callPackage ./overlayed.nix { };
  thorium = pkgs.callPackage ./thorium.nix { };

  # Replace with custom crafted package
  findUnicode = pkgs.callPackage ./findUnicode.nix { };

  # Import packages defined in foreign repositories
  inherit (agenix.packages.${system}) agenix;
  inherit (git-leave.packages.${system}) git-leave;
  inherit (mind.packages.${system}) mind;
  inherit (radicle.packages.${system}) radicle-cli radicle-remote-helper radicle-httpd radicle-node;
}
