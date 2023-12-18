{ self, lib, ... }@pkgs:

with lib;

let

  inherit (self.outputs) nixosConfigurations;

in
mapAttrs (_: program: { type = "app"; inherit program; }) (
  {
    # Put apps here
  }

  // mapAttrs' (name: value: nameValuePair "flash-iso-${name}" (import ./flash-installer.nix value pkgs)) nixosConfigurations
)
