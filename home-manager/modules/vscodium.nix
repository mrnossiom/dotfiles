{ lib
, pkgs
, ...
}:

with lib;

{
  config = {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      extensions = with pkgs.vscode-extensions; [
        vue.volar

      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          # https://marketplace.visualstudio.com/items?itemName=akamud.vscode-theme-onedark
          name = "vscode-theme-onedark";
          publisher = "akamud";
          version = "2.3.0";
          sha256 = "sha256-8GGv4L4poTYjdkDwZxgNYajuEmIB5XF1mhJMxO2Ho84=";
        }
      ];
    };
  };
}
