{ lib, ... }@pkgs:

with lib;

mapAttrs (_: program: { type = "app"; inherit program; }) {
  flash-iso = import ./flash-installer.nix pkgs;
}

