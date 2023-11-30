{ inputs, config, lib, pkgs, ... }:

with lib;

{
  config = {
    programs.nix-index.enableFishIntegration = false;
    programs.nix-index-database.comma.enable = true;

    programs.starship.enable = true;

    # Assumes that helix is installed, use configured version of helix
    home.sessionVariables.EDITOR = "hx";

    programs.helix = {
      enable = true;
      package = pkgs.unstable.helix;
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
        # Language server for nix
        language-server.rnix-lsp.command = "${pkgs.rnix-lsp}/bin/rnix-lsp";
        language-server.typst-lsp.command = "${pkgs.typst-lsp}/bin/typst-lsp";

        grammar = [
          # Doesn't work
          {
            name = "typst";
            source = { git = "https://github.com/frozolotl/tree-sitter-typst"; rev = "master"; };
          }
        ];

        language = [
          {
            name = "nix";
            language-servers = [ "rnix-lsp" ];
            auto-format = true;
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
        ls = "${pkgs.eza}/bin/eza --color=auto $argv";
      };

      shellAbbrs = {
        # One letter abbrs
        b = "bun";
        c = "cargo";
        d = "docker";
        g = "git";
        j = "just";

        # Docker
        dcu = "docker compose up -d";
        dcd = "docker compose down";

        # Edit utilities
        rm = "rm -i";
        rmd = "rm -rd";
        cp = "cp -iv";
        ln = "ln -v";
        mv = "mv -iv";
        mkdir = "mkdir -v";

        # Listing utilities
        l = "ls -GlhFa";
        ll = "ls -lhFa";
        ls = "ls -Fa";
        ld = "ls -FD";
        tree = "ls -T";

        # Renamed tools
        grep = "rg";
        cat = "bat";
        diff = "delta";

        # Nix-related
        ns = "nix-shell -p";

        # Do not keep these commands in history
        shutdown = " shutdown";
        clr = " clear";
        reboot = " reboot";
        history = " history";
        exit = " exit";
      };

      functions = {
        # Fish specific
        fish_greeting = ''
          echo 'Hello '(set_color brblue)(whoami)(set_color normal)' you are on '(set_color brred)(uname)(set_color normal)'.'
          echo 'Current directory is '(set_color brgreen)(pwd)(set_color normal)
        '';
        last_history_item = "echo $history[1]";

        change-mac = ''
          set dev (nmcli --get-values GENERAL.DEVICE,GENERAL.TYPE device show | sed '/^wifi/!{h;d;};x;q')
          sudo ip link set $dev down
    
          if test "$argv[1]" = "reset";
              sudo ${pkgs.macchanger}/bin/macchanger --permanent $dev
          else;
              sudo ${pkgs.macchanger}/bin/macchanger --another $dev
          end

          sudo ip link set $dev up
        '';

        # Quickly cd into a derivation
        # NOTE: another channel can be specified after the derivation, tail uses the last derivation
        # e.g. `cdd fontforge` or `cdd fontforge '<nixpkgs-unstable>'`
        cdd = "cd (nix-build --no-out-link '<nixpkgs>' -A $argv | tail -n1)";
      };
    };
  };
}
