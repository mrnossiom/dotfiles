{ self
, config
, pkgs
, lpkgs
, upkgs
, lib
, ...
}:

let
  inherit (self) homeManagerModules;
  # inherit (config.age) secrets;

  flags = config.local.flags;
  cfg = config.local.fragment.helix;
in
{
  imports = [ homeManagerModules.wakatime ];

  options.local.fragment.helix.enable = lib.mkEnableOption ''
    Helix editor related
  '';

  config = lib.mkIf cfg.enable {
    programs.helix = {
      enable = true;
      package = if flags.onlyCached then pkgs.helix else lpkgs.helix;
      defaultEditor = true;

      settings = {
        theme = "onedark";
        editor = {
          auto-format = true;
          auto-save = true;
          bufferline = "multiple";
          line-number = "relative";
          mouse = false;
          rulers = [ 80 ];
          text-width = 80;

          indent-guides = {
            render = true;
            characters = "╎";
          };

          file-picker.hidden = false;

          lsp.display-inlay-hints = false;

          soft-wrap.wrap-at-text-width = true;
        };
        keys =
          let
            disable-arrow-keys = false;
            noop-arrow-keys = lib.optionalAttrs disable-arrow-keys { up = "no_op"; down = "no_op"; left = "no_op"; right = "no_op"; };
          in
          {
            normal = {
              "space" = {
                # Swap original keybinds, default (lowercase) searches in `pwd`
                f = "file_picker_in_current_directory";
                F = "file_picker";
              };

              # Toggle inlay hints
              "A-u" = ":toggle lsp.display-inlay-hints";
              # Toogle wrapping
              # TODO: change to `soft-wrap.enable` when supported by `:toggle`
              "A-w" = ":toggle soft-wrap.wrap-at-text-width";

              # TODO: try to have `d`,`c` noyank versions by default
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
        lpkgs.wakatime-lsp
      ];

      languages = {
        language-server = {
          rust-analyzer.config = { check.command = "clippy"; };

          ltex-ls.command = "ltex-ls";
          wakatime.command = "wakatime-lsp";
        };

        language = [
          { name = "c"; auto-format = true; formatter = { command = lib.getExe' pkgs.clang-tools "clang-format"; args = [ ]; }; }
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

    # programs.wakatime = {
    #   enable = true;
    #   apiKeyFile = secrets.api-wakatime.path;
    #   settings = {
    #     exclude_unknown_project = true;
    #   };
    # };
  };
}
