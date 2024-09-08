{ pkgs
, lib
, config
, ...
}:

let
  cfg = config.local.fragment.chromium;
in
{
  options.local.fragment.chromium.enable = lib.mkEnableOption ''
    Chromium and extensions
  '';

  config = lib.mkIf cfg.enable {
    programs.chromium = {
      enable = true;

      dictionaries = with pkgs.hunspellDictsChromium; [ en_US fr_FR ];

      extensions = [
        # Language Tool
        { id = "oldceeleldhonbafppcapldpdifcinji"; }
        # Bitwarden
        { id = "nngceckbapebfimnlniiiahkandclblb"; }
        # Vue DevTools
        { id = "nhdogjmejiglipccpnnnanhbledajbpd"; }
        # React DevTools
        { id = "fmkadmapgofadopljbjfkapdkoienihi"; }
      ];
    };
  };
}

