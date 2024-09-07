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
        bradlc.vscode-tailwindcss
        dbaeumer.vscode-eslint
        eamodio.gitlens
        esbenp.prettier-vscode
        usernamehw.errorlens
        vue.volar
        wakatime.vscode-wakatime
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          # https://marketplace.visualstudio.com/items?itemName=meganrogge.template-string-converter
          name = "template-string-converter";
          publisher = "meganrogge";
          version = "0.6.1";
          sha256 = "sha256-w0ppzh0m/9Hw3BPJbAKsNcMStdzoH9ODf3zweRcCG5k=";
        }
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
