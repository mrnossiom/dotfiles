{ system, ... }@pkgs:

let
  git-leave = builtins.getFlake "github:mrnossiom/git-leave/a4358d2769c0f93a5c8f7e7eb17e46f69e44d69e";
  rad = builtins.getFlake "git+https://seed.radicle.xyz/z3gqcJUoA1n9HaHKufZs5FCSGazv5?rev=150130e99beb04cd5d989932a617fcd160c7345a";
in
{
  thorium = pkgs.callPackage ./thorium.nix { };
  greenlight = pkgs.callPackage ./greenlight.nix { };
  # Replace with custom crafted package
  findUnicode = pkgs.callPackage ./findUnicode.nix { };

  # Import packages defined in foreign repositories
  # IDEA: move to a NUR repository
  inherit (git-leave.packages.${system}) git-leave;
  inherit (rad.packages.${system}) radicle-cli radicle-remote-helper radicle-httpd radicle-node;
}
