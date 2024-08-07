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
      package = pkgs.helix;
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
          lsp.display-inlay-hints = false;
          soft-wrap.wrap-at-text-width = true;
          rulers = [ 80 ];
        };
        keys =
          let
            disable-arrow-keys = false;
            noop-arrow-keys = optionalAttrs disable-arrow-keys { up = "no_op"; down = "no_op"; left = "no_op"; right = "no_op"; };
          in
          {
            normal = {
              "space" = {
                f = "file_picker_in_current_directory";
                F = "file_picker";
              };
            } // noop-arrow-keys;
            insert = noop-arrow-keys;
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
        upkgs.vue-language-server
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
          { name = "c"; auto-format = true; formatter = { command = getExe' pkgs.clang-tools "clang-format"; args = [ ]; }; }
          { name = "html"; language-servers = [ "vscode-html-language-server" "wakatime" ]; }
          { name = "markdown"; language-servers = [ "marksman" "wakatime" ]; }
          { name = "nix"; language-servers = [ "nil" "wakatime" ]; auto-format = true; }
          { name = "python"; language-servers = [ "pylsp" "wakatime" ]; }
          { name = "rust"; language-servers = [ "rust-analyzer" "wakatime" ]; }
          { name = "typescript"; language-servers = [ "typescript-language-server" "wakatime" ]; }
          { name = "vue"; language-servers = [ "vuels" "typescript-language-server" "wakatime" ]; }
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
