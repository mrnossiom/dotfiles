{ lib, system, ... }: (lib.nixosSystem { inherit system; modules = [ ../nixos/profiles/installer.nix ]; }).config.system.build.isoImage
