{ lib, pkgs, ... }:

with lib;

{
  config = {
    programs.starship = {
      enable = true;
      settings.nix_shell = {
        format = "via [$symbol$state]($style) "; # Remove nix shell name
        symbol = " ";
      };
    };

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
          file-picker.hidden = false;
          lsp.display-inlay-hints = true;
          soft-wrap.wrap-at-text-width = true;
        };
        keys = rec {
          insert = {
            up = "no_op";
            down = "no_op";
            left = "no_op";
            right = "no_op";
          };
          # Work the same in normal mode
          normal = insert;
        };
      };
      languages = {
        language-server = with pkgs;
          let
            # Allows to have LSP for pretty much everylanguage I can encounter without overriding the ones in env
            exeOrFallback = exe: fallbackPkg: writeShellScript "exe-or-fallback-${exe}" ''
              [ -x "$(command -v ${exe})" ] && ${exe} || ${getExe' fallbackPkg exe}
            '';
          in
          {
            # Language server for nix
            nil.command = exeOrFallback "nil" nil;
            typst-lsp.command = exeOrFallback "typst-lsp" typst-lsp;

            # Default language servers
            clangd.command = exeOrFallback "clangd" clang-tools;
            gopls.command = exeOrFallback "gopls" gopls;
            marksman.command = exeOrFallback "marksman" marksman;
            pylsp.command = exeOrFallback "pylsp" python311Packages.python-lsp-server;
            tuplo.command = exeOrFallback "taplo" taplo;
            typescript-language-server.command = exeOrFallback "typescript-language-server" nodePackages.typescript-language-server;
            vscode-css-language-server.command = exeOrFallback "vscode-css-language-server" vscode-langservers-extracted;
            vscode-html-language-server.command = exeOrFallback "vscode-html-language-server" vscode-langservers-extracted;
            vscode-json-language-server.command = exeOrFallback "vscode-json-language-server" vscode-langservers-extracted;
            yaml-language-server.command = exeOrFallback "yaml-language-server" yaml-language-server;
            ansible-language-server.command = exeOrFallback "ansible-language-server" ansible-language-server;
          };

        grammar = [{
          # TODO: broken
          name = "typst";
          source = { git = "https://github.com/frozolotl/tree-sitter-typst"; rev = "master"; };
        }];

        language = [
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

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    # Entering in shells is indicated by starship
    home.sessionVariables.DIRENV_LOG_FORMAT = "";

    programs.zellij = {
      enable = true;
      settings = {
        default_layout = "compact";
      };

      # TODO: modify HM module to define layouts in here directly
    };

    programs.nushell = {
      enable = true;

      extraConfig = ''
        $env.config = {
          show_banner: false,
        }
      '';
    };


    programs.fish = {
      enable = true;

      loginShellInit = ''
        if test (id --user $USER) -ge 1000 && test (tty) = "/dev/tty1"
          exec sway
        end
      '';

      interactiveShellInit = ''
        abbr -a !! --position anywhere --function last_history_item
      '';

      shellAliases = {
        # Use `eza` for `ls` invocations
        #
        # This is also a more pure version than using `__fish_ls_*` variables
        # that depends on fish internal ls wrappers and can be overriden by
        # bad configuration. (e.g. NixOS `environment.shellAliases` default)
        ls = "${getExe pkgs.eza} --color=auto --icons=auto --hyperlink";

        tb = "nc termbin.com 9999";
      };

      shellAbbrs = {
        # One letter abbrs
        c = "cargo";
        d = "docker";
        g = "git";
        j = "just";
        n = "nix";

        # Edit utilities
        rm = "rm -i";
        rmd = "rm -rd";
        cp = "cp -iv";
        ln = "ln -v";
        mv = "mv -iv";
        mkdir = "mkdir -v";

        # Listing utilities
        l = "ls -Fa";
        ll = "ls -lhFa";
        ld = "ls -FD";
        tree = "ls -T";

        # Renamed tools
        grep = "rg";
        cat = "bat";
        diff = "delta";

        # Nix-related
        ur = " unlink result";

        # Do not keep these commands in history
        shutdown = " shutdown";
        clr = " clear";
        reboot = " reboot";
        history = " history";
        exit = " exit";
      };

      functions = {
        # Executed on interactive shell start, greet with a short quote
        fish_greeting = "${getExe pkgs.fortune} -s";

        # Used in interactiveShellInit
        last_history_item = "echo $history[1]";

        # Quickly get outta here to test something
        cdtmp = ''
          set -l tmp /tmp/(${getExe pkgs.names})
          mkdir $tmp
          cd $tmp
        '';

        change-mac = ''
          set dev (nmcli --get-values GENERAL.DEVICE,GENERAL.TYPE device show | sed '/^wifi/!{h;d;};x;q')
          sudo ip link set $dev down
    
          if test "$argv[1]" = "reset";
              sudo ${getExe pkgs.macchanger} --permanent $dev
          else;
              sudo ${getExe pkgs.macchanger} --ending --another $dev
          end

          sudo ip link set $dev up
        '';

        repeat = ''
          set -l command (string join ' ' -- $argv)

          while true
              # Prompt for package name
              read -P "\$ "(set_color brgreen)"$command "(set_color normal) package_name

              # Check if nothing was entered to quit
              test "$package_name" = "" && break

              # Run 'apt info' command with the provided package name
              fish -c "$command $package_name"
          end
        '';

        nix-develop = "nix develop $argv --command fish";

        # Quickly explore a derivation (using registry syntax)
        # e.g. `cdd nixpkgs#fontforge` or `cdd nixpkgs-unstable#fontforge` 
        cdd = "cd (nix build --no-link --print-out-paths $argv | tail -n1)";
      };
    };
  };
}
