{ config, lib, pkgs, ... }:

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

        comboListToString = foldl (acc: val: acc + "<${val}> ") "";
        sanitizeComboResult = escape [ ''"'' ];

        comboSetToList = ip: flatten (mapAttrsToList
          (name: value:
            if isAttrs value then
              let vs = comboSetToList value;
              in
              map ({ combo, value }: { combo = [ name ] ++ combo; inherit value; }) vs
            else if isString value then
              { combo = [ name ]; inherit value; }
            else throw "combo value must be a string"
          )
          ip);
        complexListToSimple = map ({ combo, value }: { combo = comboListToString combo; value = sanitizeComboResult value; });
        toComposeFile = foldl (acc: val: acc + "${val.combo}: \"${val.value}\"\n") "";

        processComposeSet = set: toComposeFile (complexListToSimple (comboSetToList set));

      in
      ''
        ${optionalString cfg.includeLocaleCompose "include \"%L\""}

        ${processComposeSet cfg.sequences}
      '';
  };
}
