{ self
, config
, pkgs
, lpkgs
, lib
, ...
}:

let
  inherit (self) homeManagerModules;
  inherit (config.age) secrets;

  flags = config.local.flags;
  cfg = config.local.fragment.helix;
in
{
  imports = [ homeManagerModules.wakatime ];

  options.local.fragment.helix.enable = lib.mkEnableOption ''
    Helix editor related

    Depends on:
    - `agenix` fragment: WakaTime key
  '';

  config = lib.mkIf cfg.enable {
    assertions = [
      { assertion = config.local.fragment.agenix.enable; message = "`helix` fragment depends on `agenix` fragment"; }
    ];

    programs.helix = {
      enable = true;
      package = if flags.onlyCached then pkgs.helix else lpkgs.helix;
      defaultEditor = true;

      settings = {
        theme = "onedark";
        editor = {
          auto-format = true;
          auto-info = false;
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
        taplo
        typst-lsp
        vscode-langservers-extracted
        yaml-language-server
      ] ++ lib.optionals (!flags.onlyCached) [
        lpkgs.wakatime-ls
      ];

      languages = {
        language-server = {
          rust-analyzer.config = { check.command = "clippy"; };

          ltex-ls.command = "ltex-ls";
          wakatime-ls.command = "wakatime-ls";
        };

        language =
          let global-lsps = [ "wakatime-ls" ]; in
          [
            { name = "c"; language-servers = [ "clangd" ] ++ global-lsps; auto-format = true; formatter = { command = lib.getExe' pkgs.clang-tools "clang-format"; args = [ ]; }; }
            { name = "html"; language-servers = [ "vscode-html-language-server" ] ++ global-lsps; }
            { name = "markdown"; language-servers = [ "marksman" ] ++ global-lsps; }
            { name = "nix"; language-servers = [ "nil" ] ++ global-lsps; auto-format = true; }
            { name = "python"; language-servers = [ "ruff" "jedi" "pylsp" ] ++ global-lsps; }
            { name = "rust"; language-servers = [ "rust-analyzer" ] ++ global-lsps; }
            { name = "typescript"; language-servers = [ "typescript-language-server" ] ++ global-lsps; }
            { name = "vue"; language-servers = [ "vuels" "typescript-language-server" ] ++ global-lsps; }
            { name = "ocaml"; language-servers = [ "ocamllsp" ] ++ global-lsps; }
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
