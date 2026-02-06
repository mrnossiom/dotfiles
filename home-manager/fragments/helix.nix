{
  self,
  config,
  pkgs,
  upkgs,
  lpkgs,
  lib,
  ...
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
      {
        assertion = config.local.fragment.agenix.enable;
        message = "`helix` fragment depends on `agenix` fragment";
      }
    ];

    stylix.targets.helix.enable = false;

    programs.helix = {
      enable = true;
      package = upkgs.helix;
      defaultEditor = true;

      settings = {
        theme = lib.mkDefault "wolf-alabaster-dark";

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

      extraPackages =
        with pkgs;
        [
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
        ]
        ++ lib.optionals (!flags.onlyCached) [
          lpkgs.ebnfer
          lpkgs.wakatime-ls
        ];

      languages = {
        language-server = {
          rust-analyzer.config = {
            check.command = "clippy";
          };

          ebnfer.command = "ebnfer";

          typos-ls.command = "typos-lsp";
          wakatime-ls.command = "wakatime-ls";
        };

        language =
          let
            global-language-servers = [
              "wakatime-ls"
              "typos-ls"
            ];
            mk-lang =
              name: language-servers: extra:
              {
                inherit name;
                language-servers = language-servers ++ global-language-servers;
              }
              // extra;
          in
          [
            (mk-lang "html" [ "vscode-html-language-server" ] { })
            (mk-lang "markdown" [ "marksman" ] { })
            (mk-lang "nix" [ "nil" ] { })
            (mk-lang "ocaml" [ "ocamllsp" ] { })
            (mk-lang "python" [ "ruff" "jedi" "pylsp" ] { })
            (mk-lang "rust" [ "rust-analyzer" ] { })
            (mk-lang "typescript" [ "typescript-language-server" ] { })
            (mk-lang "zig" [ "zls" ] { })

            (mk-lang "c" [ "clangd" ] {
              formatter = {
                command = lib.getExe' pkgs.clang-tools "clang-format";
                args = [ ];
              };
            })

            # TODO: remove when merged upstream
            (mk-lang "ebnf" [ "ebnfer" ] {
              scope = "source.ebnf";
              injection-regex = "ebnf";
              file-types = [ "ebnf" ];
              indent = {
                tab-width = 4;
                unit = "    ";
              };
              block-comment-tokens = {
                start = "(*";
                end = "*)";
              };
            })
          ];

        grammar = [
          {
            name = "ebnf";
            source = {
              git = "https://github.com/RubixDev/ebnf/";
              rev = "8e635b0b723c620774dfb8abf382a7f531894b40";
              subpath = "crates/tree-sitter-ebnf";
            };
          }
        ];
      };
    };

    age.secrets.api-wakatime.file = ../../secrets/api-wakatime.age;
    age.secrets.api-wakapi.file = ../../secrets/api-wakapi.age;
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
