{ self, system, ... }@pkgs:

let
  inherit (self.inputs) git-leave radicle;
in
{
  thorium = pkgs.callPackage ./thorium.nix { };
  greenlight = pkgs.callPackage ./greenlight.nix { };

  # Replace with custom crafted package
  findUnicode = pkgs.callPackage ./findUnicode.nix { };

  # Import packages defined in foreign repositories
  # IDEA: move to a NUR repository
  inherit (git-leave.packages.${system}) git-leave;
  inherit (radicle.packages.${system}) radicle-cli radicle-remote-helper radicle-httpd radicle-node;
}
