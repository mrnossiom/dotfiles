{ self
, config
, lib
, pkgs
, ...
}:

let
  inherit (self.outputs) homeManagerModules;
in
{
  imports = [ homeManagerModules.xcompose ];

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
