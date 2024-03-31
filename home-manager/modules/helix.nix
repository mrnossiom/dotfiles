{ pkgs, lib, ... }:
with lib;
{
  config = {
    programs.helix = {
      enable = true;
      defaultEditor = true;

      settings = {
        theme = "onedark";
        editor = {
          auto-save = true;
          auto-format = true;
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
      ];

      languages = {
        language-server = {
          rust-analyser = {
            config = { check.command = "clippy"; };
            command = "rust-analyser";
          };

          typst-lsp.command = "typst-lsp";
          ltex-ls.command = "ltex-ls";
        };


        grammar = [{
          # TODO: broken
          name = "typst";
          source = { git = "https://github.com/frozolotl/tree-sitter-typst"; rev = "master"; };
        }];

        language = [
          {
            name = "markdown";
            language-servers = [ "marksman" ];
          }
          {
            name = "nix";
            language-servers = [ "nil" ];
            auto-format = true;
          }
          {
            name = "c";
            auto-format = true;
            formatter = { command = getExe' pkgs.clang-tools "clang-format"; args = [ ]; };
          }
          {
            name = "typst";
            scope = "source.typst";
            auto-format = true;
            language-servers = [ "typst-lsp" ];
            file-types = [ "typ" ];
            roots = [ "typst.toml" ];
            comment-token = "//";
            indent = { tab-width = 4; unit = "\t"; };
            auto-pairs = { "(" = ")"; "{" = "}"; "[" = "]"; "\"" = "\""; "`" = "`"; "$" = "$"; };
            injection-regex = "^typ(st)?$";
            grammar = "typst";
          }
        ];
      };
    };
  };
}
