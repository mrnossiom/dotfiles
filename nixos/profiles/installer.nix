{ lib, modulesPath, ... }:

{
  imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-graphical-base.nix" ];

  config = {
    # Default compression is never-ending, this gets done in a minute with better results
    isoImage.squashfsCompression = "zstd -Xcompression-level 10";

    # Disable annoying warning
    boot.swraid.enable = lib.mkForce false;
  };
}
