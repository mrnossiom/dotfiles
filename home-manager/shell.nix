{ config, lib, pkgs, ... }:
with lib;
{
  config = {
    programs.nix-index.enableFishIntegration = false;
    programs.nix-index-database.comma.enable = true;

    programs.starship.enable = true;

    programs.helix = {
      enable = true;
      package = pkgs.unstable.helix;
      settings = {
        theme = "onedark";
        editor = {
          line-number = "relative";
          mouse = false;
          indent-guides = {
            render = true;
            characters = "╎";
          };
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

        language = [{
          name = "nix";
          language-servers = [ "rnix-lsp" ];
        }];
      };
    };

    programs.fish = {
      enable = true;

      # TODO: verify security and check swayidle
      loginShellInit = ''
        if test (id --user $USER) -ge 1000 && test (tty) = "/dev/tty1"
          exec sway
        end
      '';

      interactiveShellInit = ''
        # Use exa instead of ls
        set -U __fish_ls_command ${pkgs.exa}/bin/exa
        set -U __fish_ls_color_opt '--color=auto'

        abbr -a !! --position anywhere --function last_history_item
      '';

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

        # Quickly cd into a derivation
        # NOTE: another channel can be specified after the derivation, tail uses the last derivation
        # e.g. `cdd fontforge` or `cdd fontforge '<nixpkgs-unstable>'`
        cdd = "cd (nix-build --no-out-link '<nixpkgs>' -A $argv | tail -n1)";
      };
    };
  };
}
