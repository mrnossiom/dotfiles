{ forAllPkgs }:

{ lib
, ...
}@pkgs:

with lib;

let
  apps = {
    # app = exec
  };

  # Installer ISOs do need to consider target architecture
  # We matrix over all systems to make `flash-installer-iso-${targetSystem}`
  flash-installer-iso-matrix = mapAttrs'
    (name: value: { name = "flash-installer-iso-${name}"; inherit value; })
    (forAllPkgs (targetPkg: (import ./flash-installer.nix targetPkg) pkgs));

  all-apps = apps // flash-installer-iso-matrix;
in

mapAttrs (_: program: { type = "app"; inherit program; }) all-apps
