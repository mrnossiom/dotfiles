{
  flake.diskoConfigurations.hetzner-ext4 = {
    disko.devices.disk.primary = {
      type = "disk";
      device = "/dev/sda";

      content = {
        type = "gpt";

        partitions.boot = {
          size = "1M";
          type = "EF02";
          priority = 1;
        };

        partitions.ESP = {
          size = "512M";
          type = "EF00";

          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };

        partitions.root = {
          size = "100%";

          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
