{ pkgs-per-system }:

{ lib
, ...
}@pkgs:

let
  apps = {
    flash-installer-iso-x86_64-linux = import ./flash-installer.nix pkgs-per-system.x86_64-linux pkgs;
  };
in

lib.mapAttrs (_: program: { type = "app"; inherit program; }) apps
