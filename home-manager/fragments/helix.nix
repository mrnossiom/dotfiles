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
        theme = lib.mkDefault "monokai_pro_octagon";

        editor = {
          auto-format = true;
          auto-info = false;
          auto-save = true;

          bufferline = "multiple"; # Show open buffers as tabs
          line-number = "relative";

          mouse = false;

          end-of-line-diagnostics = "hint";
          inline-diagnostics = {
            cursor-line = "error";
            other-lines = "error";
          };

          indent-guides = {
            render = true;
            characters = "╎";
          };

          file-picker.hidden = false;

          lsp.display-inlay-hints = false;

          rulers = [ 80 ];
          text-width = 80;
          soft-wrap.wrap-at-text-width = true;
        };

        keys = {
          normal = {
            "space" = {
              # Swap original keybinds, default (lowercase) searches in `pwd`
              f = "file_picker_in_current_directory";
              F = "file_picker";
            };

            # Toggle inlay hints
            "A-u" = ":toggle lsp.display-inlay-hints";
            # Toggle wrapping
            # TODO: change to `soft-wrap.enable` when supported by `:toggle`
            "A-w" = ":toggle soft-wrap.wrap-at-text-width";
          };
          insert = {
            up = "no_op";
            down = "no_op";
            left = "no_op";
            right = "no_op";
          };
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
        typos-lsp
        vscode-langservers-extracted
        yaml-language-server
      ] ++ lib.optionals (!flags.onlyCached) [
        lpkgs.wakatime-ls
      ];

      languages = {
        language-server = {
          rust-analyzer.config = { check.command = "clippy"; };

          ltex-ls.command = "ltex-ls";
          typos-ls.command = "typos-lsp";
          wakatime-ls.command = "wakatime-ls";
        };

        language =
          let
            global-lsps = [ "wakatime-ls" "typos-ls" ];
            mk-lang = name: language-servers: extra: { inherit name; language-servers = language-servers ++ global-lsps; } // extra;
          in
          [
            (mk-lang "c" [ "clangd" ] {
              formatter = { command = lib.getExe' pkgs.clang-tools "clang-format"; args = [ ]; };
            })
            (mk-lang "markdown" [ "marksman" ] {
              soft-wrap.enable = true;
            })

            (mk-lang "html" [ "vscode-html-language-server" ] { })
            (mk-lang "nix" [ "nil" ] { })
            (mk-lang "ocaml" [ "ocamllsp" ] { })
            (mk-lang "python" [ "ruff" "jedi" "pylsp" ] { })
            (mk-lang "rust" [ "rust-analyzer" ] { })
            (mk-lang "typescript" [ "typescript-language-server" ] { })
            (mk-lang "zig" [ "zls" ] { })
          ];
      };
    };

    programs.wakatime = {
      enable = true;
      apiKeyFile = secrets.api-wakapi.path;
      settings = {
        api_url = "https://wakapi.dev/api";

        exclude_unknown_project = true;
      };
    };
  };
}
