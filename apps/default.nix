{ pkgs-per-system }:

{ self
, lib
, ...
}@pkgs:

let
  inherit (self.outputs) flake-lib;

  iso-x86_64-linux = flake-lib.nixos.createSystem pkgs-per-system.x86_64-linux [ ../nixos/profiles/installer.nix ];
  path-iso-x86_64-linux = "${iso-x86_64-linux.config.system.build.isoImage}/iso/${iso-x86_64-linux.config.isoImage.isoName}";

  iso-rpi = flake-lib.nixos.createSystem pkgs-per-system.aarch64-linux [ ../nixos/profiles/installer-rpi.nix ];
  path-iso-rpi = "${iso-rpi.config.system.build.sdImage}/iso/${iso-rpi.config.sdImage.isoName}";

  apps = {
    inherit iso-rpi;
  
    installer-iso-x86_64-linux = import ./flash-installer.nix pkgs path-iso-x86_64-linux;
    installer-rpi = import ./flash-installer.nix pkgs path-iso-rpi;
  };
in
lib.mapAttrs (_: program: { type = "app"; inherit program; }) apps
