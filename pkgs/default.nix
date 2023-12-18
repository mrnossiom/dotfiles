{ system, ... }@pkgs:

let

  git-leave = builtins.getFlake "github:mrnossiom/git-leave/a4358d2769c0f93a5c8f7e7eb17e46f69e44d69e";

in
{
  thorium = pkgs.callPackage ./thorium.nix { };
  greenlight = pkgs.callPackage ./greenlight.nix { };

  # Import packages defined in foreign repositories
  # IDEA: move to a NUR repository
  git-leave = git-leave.packages.${system}.git-leave;
}
