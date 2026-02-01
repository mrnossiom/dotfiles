{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.xcompose;
in
{
  options.programs.xcompose = {
    enable = lib.mkEnableOption "XCompose keyboard configuration";

    loadConfigInEnv = lib.mkOption {
      description = ''
        Load the XCompose file by passing the `XCOMPOSEFILE` environment variable instead of linking to ~/.XCompose.

        That is nice to avoid cluttering the HOME directory, it's preferable to disable it when experimenting
        with your compose config to reload faster than having to reload your VM.
      '';
      default = true;
      type = lib.types.bool;
    };

    includeLocaleCompose = lib.mkOption {
      description = "Whether to include the base libX11 locale compose file";
      default = false;
      type = lib.types.bool;
    };

    sequences = lib.mkOption {
      description = ''
        Shapeless tree of macros
        - Keys name can be easily found with wev (or xev)
        - https://www.compart.com/en/unicode — Lists all Unicode characters
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
      type = lib.types.anything;
    };

    extraConfig = lib.mkOption {
      description = ''
        Unmanaged xcompose sequences and directives
      '';
      default = "";
      example = ''
        <Multi_key> <Multi_key> <a> <5> : "٥"
      '';
      type = lib.types.lines;
    };
  };

  config =
    let
      comboListToString = lib.foldl (acc: val: acc + "<${val}> ") "";
      sanitizeComboResult = lib.escape [ ''"'' ];

      comboSetToList =
        ip:
        lib.flatten (
          lib.mapAttrsToList (
            name: value:
            if lib.isAttrs value then
              let
                vs = comboSetToList value;
              in
              map (
                { combo, value }:
                {
                  combo = [ name ] ++ combo;
                  inherit value;
                }
              ) vs
            else if lib.isString value then
              {
                combo = [ name ];
                inherit value;
              }
            else
              throw "combo value must be a string"
          ) ip
        );
      complexListToSimple = map (
        { combo, value }:
        {
          combo = comboListToString combo;
          value = sanitizeComboResult value;
        }
      );
      toComposeFile = lib.foldl (acc: val: acc + "${val.combo}: \"${val.value}\"\n") "";

      processComposeSet = set: toComposeFile (complexListToSimple (comboSetToList set));

      # TODO: see if include changes if put after compose declarations
      composeFile = pkgs.writeText "XCompose" ''
        ${lib.optionalString cfg.includeLocaleCompose "include \"%L\""}
        ${processComposeSet cfg.sequences}
        ${cfg.extraConfig}
      '';
    in
    lib.mkIf cfg.enable {
      home.sessionVariables = lib.mkIf cfg.loadConfigInEnv { XCOMPOSEFILE = composeFile; };
      home.file = lib.mkIf (!cfg.loadConfigInEnv) { ".XCompose".source = composeFile; };
    };
}
