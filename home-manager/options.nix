{
  lib,
  ...
}:

{
  options.local = {
    flags = {
      onlyCached = lib.mkOption {
        description = "Whether to limit the number of pkgs to compile on device";
        type = lib.types.bool;
        default = false;
      };
    };
  };
}
