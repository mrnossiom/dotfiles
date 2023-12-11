{ lib, ... }@pkgs: lib.mapAttrs (_: program: { type = "app"; inherit program; }) {
  flash-installer = import ./flash-installer.nix pkgs;
}
