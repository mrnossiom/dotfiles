# This flake library is available to modules via the `llib` arg
pkgs: with pkgs.lib; {
  colorSchemes = import ./colorSchemes.nix;

  createFragment = name: config: {
    options."${name}".enable = mkOption {
      description = "Whether to enable `${name}` fragment";
      type = types.bool;
    };

    config = mkIf true config;
  };
}
