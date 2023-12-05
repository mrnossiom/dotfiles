{ config
, lib
, pkgs
, outputs
, ...
}: {
  imports = [ outputs.homeManagerModules.xcompose ];

  options = { };

  config.programs.xcompose = {
    enable = true;
    includeLocaleCompose = true;

    sequences = {
      Multi_key = {
        comma = "̧";
        h.i = "helo";
      };
    };
  };
}
