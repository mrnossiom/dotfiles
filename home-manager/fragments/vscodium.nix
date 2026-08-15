{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.local.fragment.vscodium;
in
{
  options.local.fragment.vscodium.enable = lib.mkEnableOption ''
    VSCodium related
  '';

  config = lib.mkIf cfg.enable {
    programs.vscodium = {
      enable = true;
      profiles.default = {
        userSettings = {
          window.autoDetectColorScheme = true;
          workbench.preferredLightColorTheme = "Alabaster";
          workbench.preferredDarkColorTheme = "Alabaster Dark";

          explorer.excludeGitIgnore = true;
          files.autoSave = "onFocusChange";
          editor.minimap.enabled = false;
        };

        extensions =
          with pkgs.vscode-extensions;
          [
            dbaeumer.vscode-eslint
            eamodio.gitlens
            esbenp.prettier-vscode
            mkhl.direnv
            ms-vsliveshare.vsliveshare
            usernamehw.errorlens
          ]
          ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            {
              # https://marketplace.visualstudio.com/items?itemName=meganrogge.template-string-converter
              name = "template-string-converter";
              publisher = "meganrogge";
              version = "0.6.1";
              sha256 = "sha256-w0ppzh0m/9Hw3BPJbAKsNcMStdzoH9ODf3zweRcCG5k=";
            }
            {
              # https://open-vsx.org/extension/tonsky/theme-alabaster
              name = "theme-alabaster";
              publisher = "tonsky";
              version = "0.2.9";
              sha256 = "sha256-3LvXIJAyKUqgxAsC7fa48YRqX3/5UByMhYCQxnuKJm4=";
            }
            {
              # https://open-vsx.org/extension/lao-liang/vscode-theme-alabaster-dark
              name = "vscode-theme-alabaster-dark";
              publisher = "lao-liang";
              version = "0.0.2";
              sha256 = "sha256-tbIA+7R2KTA9vubQNpWTmGtZqdJyGA77BT6L9uA85UU=";
            }
            {
              # https://marketplace.visualstudio.com/items?itemName=gregoire.dance
              name = "dance";
              publisher = "gregoire";
              version = "0.5.16000";
              sha256 = "sha256-LOUsRQ18G4xARYO7RLz/YHvMv+Jg7ICWDG40iDjWWww=";
            }
            {
              # https://marketplace.visualstudio.com/items?itemName=gregoire.dance-helix
              name = "dance-helix";
              publisher = "gregoire";
              version = "0.1.1001";
              sha256 = "sha256-wWOlBsOJEQ8rjN3yMsegYg/8t3Jy6Gz/RyCn4/Ts7ZE=";
            }
          ];
      };
    };
  };
}
