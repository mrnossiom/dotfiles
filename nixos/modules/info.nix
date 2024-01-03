{ self, lib, ... }:

with lib;

{
  options.local.screen = {
    width = mkOption {
      description = "Width of the main output";
      type = types.int;
    };

    height = mkOption {
      description = "Height of the main output";
      type = types.int;
    };

    scale = mkOption {
      description = "Scale of the main output";
      default = 1;
      type = types.int;
    };
  };
}
