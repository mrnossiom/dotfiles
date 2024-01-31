{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.xcompose;
in
{
  options.programs.xcompose = {
    enable = mkEnableOption "XCompose keyboard configuration";

    loadConfigInEnv = mkOption {
      description = ''
        Load the XCompose file by passing the XCOMPOSEFILE environnement variable instead of linking to ~/.XCompose.
        
        That is nice to avoid cluttering the HOME directory, it's preferable to disable it when experimenting
        with your compose config to reload faster than having to reload your VM
      '';
      default = true;
      type = types.bool;
    };

    includeLocaleCompose = mkOption {
      description = "Wether to include the base libX11 locale compose file";
      default = false;
      type = types.bool;
    };

    sequences = mkOption {
      description = ''
        Shapeless tree of macros
        - Keys name can be easily found with wev (or xev)
        - https://www.compart.com — Lists all Unicode characters
      '';
      default = { };
      example = {
        Multi_key = {
          "g" = {
            a = "α";
            b = "β";
          };
        };
      };
      type = types.anything;
    };
  };

  config =
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

      # TODO: see if include changes if put after compose declarations
      composeFile = pkgs.writeText "XCompose" ''
        ${optionalString cfg.includeLocaleCompose "include \"%L\""}
        ${processComposeSet cfg.sequences}
      '';
    in
    mkIf cfg.enable {
      home.sessionVariables = mkIf cfg.loadConfigInEnv { XCOMPOSEFILE = composeFile; };
      home.file = mkIf (!cfg.loadConfigInEnv) { ".XCompose".source = composeFile; };
    };
}
