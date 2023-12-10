{ modulesPath, ... }: {
  imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-graphical-base.nix" ];

  config = {
    isoImage = {
      # TODO: find what is it's purpose
      edition = "yolo";
      squashfsCompression = "zstd -Xcompression-level 10";
    };
  };
}
