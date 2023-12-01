{ inputs, config, lib, pkgs, ... }:

with lib;

let

  cfg = config.programs.xcompose;

in
{
  options.programs.xcompose = {
    enable = mkEnableOption "XCompose keyboard configuration";

    includeLocaleCompose = mkOption {
      description = "Wether to include the base libX11 locale compose file";
      default = false;
      type = types.bool;
    };

    sequences = mkOption {
      description = "Shapeless tree of macros, keys name can be found <insert>";
      default = { };
      example = {
        Multi_key = {
          comma = "̧";
          h.i = "helo";
        };
      };
      type = types.anything;
    };
  };

  config = mkIf cfg.enable {
    home.file.".XCompose".text =
      let

        seqs = attrsToList cfg.sequences;

      in
      ''
        ${optionalString cfg.includeLocaleCompose "include \"%L\""}

        # Combining characters
        <Multi_key> <comma> : "̧" # Combining cedille
        <Multi_key> <h> <i> : "helo"
      '';
  };
}
