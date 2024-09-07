{ lib
, ...
}:

with lib;

{
  options.local.onlyCached = mkOption {
    description = "Whether to limit the number of pkgs to compile on device";
    type = types.bool;

    default = false;
  };
}
