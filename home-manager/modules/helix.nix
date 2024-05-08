{ self
, config
, pkgs
, upkgs
, lib
, ...
}:

with lib;

let
  inherit (self) homeManagerModules;
  inherit (config.age) secrets;
in
{
  imports = [ homeManagerModules.wakatime ];

  config = {
    programs.helix = {
      enable = true;
      package = upkgs.helix;
      defaultEditor = true;

      settings = {
        theme = "onedark";
        editor = {
          auto-save = true;
          auto-format = true;
          auto-pairs = false;
          line-number = "relative";
          mouse = false;
          text-width = 80;
          indent-guides = {
            render = true;
            characters = "╎";
          };
          bufferline = "multiple";
          file-picker.hidden = false;
          lsp.display-inlay-hints = true;
          soft-wrap.wrap-at-text-width = true;
          rulers = [ 80 ];
        };
        keys =
          let
            no_op_arrow_keys = { up = "no_op"; down = "no_op"; left = "no_op"; right = "no_op"; };
          in
          {
            normal = no_op_arrow_keys;
            insert = no_op_arrow_keys;
          };
      };

      # TODO: should change module definition to put these as suffix and avoid shadowing
      extraPackages = with pkgs; [
        ansible-language-server
        clang-tools
        gopls
        kotlin-language-server
        ltex-ls
        marksman
        nil
        nodePackages.bash-language-server
        nodePackages.typescript-language-server
        python311Packages.python-lsp-server
        taplo
        typst-lsp
        vscode-langservers-extracted
        yaml-language-server
        wakatime-lsp
      ];

      languages = {
        language-server = {
          rust-analyzer.config = { check.command = "clippy"; };

          ltex-ls.command = "ltex-ls";
          wakatime.command = "wakatime-lsp";
        };

        language = [
          {
            name = "markdown";
            language-servers = [ "marksman" "wakatime" ];
          }
          {
            name = "rust";
            language-servers = [ "rust-analyzer" "wakatime" ];
          }
          {
            name = "nix";
            language-servers = [ "nil" "wakatime" ];
            auto-format = true;
          }
          {
            name = "c";
            auto-format = true;
            formatter = { command = getExe' pkgs.clang-tools "clang-format"; args = [ ]; };
          }
        ];
      };
    };

    programs.wakatime = {
      enable = true;
      apiKeyFile = secrets.api-wakatime.path;
      settings = {
        exclude_unknown_project = true;
      };
    };
  };
}
