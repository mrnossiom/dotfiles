{ pkgs
, ...
}:

{
  config = {
    programs.chromium = {
      enable = true;

      dictionaries = with pkgs.hunspellDictsChromium; [ en_US fr_FR ];
      extensions = [
        # Language Tool
        { id = "oldceeleldhonbafppcapldpdifcinji"; }
        # Bitwarden
        { id = "nngceckbapebfimnlniiiahkandclblb"; }
        # Vue Devtools
        { id = "nhdogjmejiglipccpnnnanhbledajbpd"; }
      ];
    };
  };
}

