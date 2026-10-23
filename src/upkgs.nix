{ inputs, ... }:
{
  perSystem = { pkgs, system, ... }: {
    _module.args.upkgs = import inputs.unixpkgs {
      inherit system;
      inherit (pkgs) config;
    };
  };
}
